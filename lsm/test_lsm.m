function [outputSequence, y] = test_lsm(inputSequence, lsm, nForgetPoints, varargin)
% test_esn runs a trained ESN on a particular inputSequence

% input args:  
% inputSequence: is a nTrainingPoints * nInputUnits matrix that contains 
% the input we will run the esn on
% esn: the trained ESN structure 
% nForgetPoints: nr of initial time points to be discarded
%
% optional input argument:
% there may be one optional input, the starting vector by which the esn is
% started. The starting vector must be given as a column vector of
% dimension esn.nInternalUnits + esn.nOutputUnits + esn.nInputUnits  (that
% is, it is a total state, not an internal reservoir state). If this input
% is desired, call test_esn with fourth input 'startingState' and fifth
% input the starting vector.
%
% ouput:
% outputSequence is an array of size (size(inputSequence, 1)-nForgetPoints)
% x esn.nOutputUnits

% Created April 30, 2006, D. Popovici
% Copyright: Fraunhofer IAIS 2006 / Patent pending
% revision 1, June 6, 2006, H. Jaeger
% revision 2, June 23, 2007, H. Jaeger (added optional start state input)

	if lsm.trained == 0
	    error('The LSM is not trained. lsm.trained = 1 for a trained network') ; 
	end

	if nargin == 3
		stateCollection = compute_lsm_statematrix(inputSequence, [], lsm, nForgetPoints) ;     
	else
	    args = varargin; 
	    nargs= length(args);
	    for i=1:2:nargs
	        switch args{i},
	            case 'resetCsimStateFlag', resetCsimStateFlag = args{i+1} ; 
	            otherwise error('the option does not exist');    
	        end
	    end
	    stateCollection = ...
	        compute_lsm_statematrix(inputSequence, [], lsm, nForgetPoints, 'resetCsimStateFlag', resetCsimStateFlag) ;
	end

	y = stateCollection;

	outputSequence = stateCollection * lsm.outputWeights' ; 
	%%%% scale and shift the outputSequence back to its original size
	nOutputPoints = length(outputSequence(:,1)) ; 
	outputSequence = feval(lsm.outputActivationFunction, outputSequence); 
	outputSequence = outputSequence - repmat(lsm.teacherShift',[nOutputPoints 1]) ; 
	outputSequence = outputSequence / diag(lsm.teacherScaling) ; 

    if lsm.SpikingInput
        outputSequence = double(outputSequence > 1.0);
    end


