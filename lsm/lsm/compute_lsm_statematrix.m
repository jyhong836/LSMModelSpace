function [stateCollectMat,internalState,simStateIndex] = compute_lsm_statematrix(inputSequence, outputSequence, lsm, nForgetPoints, varargin)
% compute_statematrix  runs the input through the ESN and writes the
% obtained input+reservoir states into stateCollectMat.
% The first nForgetPoints will be deleted, as the first few states could be
% not reliable due to initial transients  
%
% inputs:
% inputSequence = input time series of size nTrainingPoints x nInputDimension
% outputSequence = output time series of size nTrainingPoints x nOutputDimension
% lsm = an ESN structure, through which we run our input sequence
% nForgetPoints: an integer, may be negative, positive or zero.
%    If positive: the first nForgetPoints will be disregarded (washing out
%    initial reservoir transient)
%    If negative: the network will be initially driven from zero state with
%    the first input repeated |nForgetPoints| times; size(inputSequence,1)
%    many states will be sorted into state matrix
%    If zero: no washout accounted for, all states except the zero starting
%    state will be sorted into state matrix
%
% Note: one of inputSequence and outputSequence may be the empty list [],
% but not both. If the inputSequence is empty, we are dealing with a purely
% generative task; states are then computed by teacher-forcing
% outputSequence. If outputSequence is empty, we are using this function to
% test a trained ESN; network output is then computed from network dynamics
% via output weights. If both are non-empty, states are computed by
% teacher-forcing outputSequence.
%
% optional input argument:
% there may be one optional input, the starting vector by which the lsm is
% started. The starting vector must be given as a column vector of
% dimension lsm.nInternalUnits + lsm.nOutputUnits + lsm.nInputUnits  (that
% is, it is a total state, not an internal reservoir state). If this input
% is desired, call test_lsm with fourth input 'startingState' and fifth
% input the starting vector.
%
% output:
% stateCollectMat = matrix of size (nTrainingPoints-nForgetPoints) x
% nInputUnits + nInternalUnits 
% stateCollectMat(i,j) = internal activation of unit j after the 
% (i + nForgetPoints)th training point has been presented to the network
%
% Modified: Junyuan Hong, 5/2015, jyhong836@gmail.com
%
% Forked from ESN
% Version 1.0, April 30, 2006
% Copyright: Fraunhofer IAIS 2006 / Patents pending
% Revision 1, June 6, 2006, H. Jaeger
% Revision 2, June 23, 2007, H. Jaeger (added optional starting state
% input)
% Revision 3, July 1, 2007, H. Jaeger (added leaky1_lsm update option)

    if isempty(inputSequence) && isempty(outputSequence)
        error('error in compute_statematrix: two empty input args');
    end

    if isempty(outputSequence)
        teacherForcing = 0;
        % TODO: when use spiking input, this should be recaculated @today
        nDataPoints = length(inputSequence(:,1));
    else
        teacherForcing = 1;
        nDataPoints = length(outputSequence(:,1));
    end

    if nForgetPoints >= 0
        stateCollectMat = ...
            zeros(nDataPoints - nForgetPoints, lsm.nInputUnits + lsm.nInternalUnits) ; 
    else
        stateCollectMat = ...
            zeros(nDataPoints, lsm.nInputUnits + lsm.nInternalUnits) ; 
    end

    resetCsimStateFlag = 1;
    args  = varargin; 
    nargs = length(args);
    for i=1:2:nargs
        switch args{i},
            case 'resetCsimStateFlag', 
                % FIXME: externalStartStateFlag is not used
                externalStartStateFlag = resetCsimStateFlag;
            otherwise error('the option does not exist'); 
        end      
    end
    if resetCsimStateFlag == 1
        csim('reset');
        lsm.simStateIndex = 0;
    end

    %%%% TODO: if nForgetPoints is negative, ramp up ESN by feeding first input
    %%%% |nForgetPoints| many times
    if nForgetPoints < 0
        % TODO: to surport the nForgetPoints<0
        warning(['WARN: nForgetPoints < 0 is not allowed now which will be fixed in the future. ' 'The internal state will not be init']);
    end

    if lsm.SpikingInput
        Tsim = lsm.dt_out*nDataPoints;
        % Set up the input
        % ALERT: default use bias one
        for i=1:lsm.nInputUnits-1
            inp(i).spiking = 1;
            inp(i).idx     = lsm.in_neus(i);
            inp(i).dt      = 0;
            in = vector2spikes(inputSequence(:,i)', lsm.dt_out);
            if resetCsimStateFlag
                inp(i).data = in;
            else
                inp(i).data = [inp(i).data, in];
            end
        end
        i = lsm.nInputUnits;
        inp(i).spiking = 0;
        inp(i).idx     = lsm.in_neus(i);
        inp(i).dt      = lsm.dt_out;
        in = lsm.inputScaling(i) .* inputSequence(:,i)' + lsm.inputShift(i);
        if resetCsimStateFlag
            inp(i).data = in;
        else
            inp(i).data = [inp(i).data, in];
        end

        % netOut as feedback
        for i=lsm.nInputUnits+1:lsm.nInputUnits+lsm.nOutputUnits
            inp(i).spiking = 1;
            inp(i).idx     = lsm.fb_neus(i - lsm.nInputUnits);
            inp(i).dt      = 0;
            if teacherForcing
                netOut = vector2spikes(outputSequence(:,i - lsm.nInputUnits)', lsm.dt_out);
            else
                netOut = [];
            end
            if resetCsimStateFlag
                inp(i).data = [0, netOut];
            else
                inp(i).data = [inp(i).data, netOut];
            end
        end

        csim('simulate', Tsim, inp);
        % internalState = csim('get',lsm.res_neus,'Vm')';
        % TODO: get recorder data
        res_response = csim('get',lsm.res_sp_recorder,'traces');
        for i=1:lsm.nInternalUnits
            internalState = spikes2vector(res_response.channel(i).data,...
                Tsim, lsm.dt_out);
            try
            stateCollectMat(:, i) = internalState(nForgetPoints+1:end);
            catch ME
                error(ME.identifier);
            end
        end
        stateCollectMat(:, lsm.nInternalUnits+1:lsm.nInternalUnits+lsm.nInputUnits)...
            = inputSequence(nForgetPoints+1:end, :); 
        internalState = stateCollectMat(:,1:lsm.nInternalUnits);
    else
        % Set up the input
        for i=1:lsm.nInputUnits
            inp(i).spiking = 0;
            inp(i).idx     = lsm.in_neus(i);
            inp(i).dt      = lsm.dt_out;
            in(i,:) = lsm.inputScaling(i) .* inputSequence(:,i)' + lsm.inputShift(i);
            if resetCsimStateFlag
                inp(i).data = in(i,:);
            else
                inp(i).data = [inp(i).data, in(i,:)];
            end
        end
        % netOut as feedback
        for i=lsm.nInputUnits+1:lsm.nInputUnits+lsm.nOutputUnits
            inp(i).spiking = 0;
            inp(i).idx     = lsm.fb_neus(i - lsm.nInputUnits);
            inp(i).dt      = lsm.dt_out;
            if teacherForcing
                netOut = lsm.teacherScaling(i - lsm.nInputUnits) .* outputSequence(1:end-1,i - lsm.nInputUnits)' + lsm.teacherShift(i - lsm.nInputUnits);
            else
                netOut = zeros(1,nDataPoints-1);
            end
            if resetCsimStateFlag
                inp(i).data = [0, netOut];
            else
                inp(i).data = [inp(i).data, 0, netOut];
            end
        end

        collectIndex = 0;
        for i = 1:nDataPoints

            csim('simulate', lsm.dt_out, inp);
            internalState = csim('get',lsm.res_neus,'Vm')';

            if ~teacherForcing    
                netOut = feval(lsm.outputActivationFunction, lsm.outputWeights * [internalState; in(:,i)]);

                for j=lsm.nInputUnits+1:lsm.nInputUnits+lsm.nOutputUnits
                    inp(j).data(lsm.simStateIndex + i+1) = netOut(j - lsm.nInputUnits);
                end
            end

            %collect state
            if nForgetPoints >= 0 &&  i > nForgetPoints
                collectIndex = collectIndex + 1;
                stateCollectMat(collectIndex,:) = [internalState' in(:,i)']; 
            elseif nForgetPoints < 0
                collectIndex = collectIndex + 1;
                stateCollectMat(collectIndex,:) = [internalState' in(:,i)']; 
            end
        end
    end
    simStateIndex = lsm.simStateIndex + nDataPoints;



