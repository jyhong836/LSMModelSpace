function [trained_lsm,stateCollection] = train_lsm(trainInput, trainOutput , lsm, nForgetPoints,val)
% TRAIN_ESN Trains the output weights of an LSM 
% In the offline case, it computes the weights using the method
% lsm.methodWeightCompute(for ex linear regression using pseudo-inverse)
% 
% inputs:
% 	trainInput = input vector of size nTrainingPoints x nInputDimension
% 	trainOutput = teacher vector of size nTrainingPoints x
% 	nOutputDimension
% 	lsm = an LSM structure, through which we run our input sequence
% 	nForgetPoints - the first nForgetPoints will be disregarded
% 
%
% outputs: 
% 	trained_lsm = an LSM structure with the option trained = 1 and 
% 	outputWeights set. 
% 	stateCollection = matrix of size (nTrainingPoints-nForgetPoints) x
% 	nInputUnits + nInternalUnits 
% 	stateCollectMat(i,j) = internal activation of unit j after the 
% 	(i + nForgetPoints)th training point has been presented to the network
% 	teacherCollection is a nSamplePoints * nOuputUnits matrix that keeps
% 	the expected output of the ESN
% 	teacherCollection is the transformed(scaled, shifted etc) output see
% 	compute_teacher for more documentation
%
% Forked from original version of ESN: 
% Created April 30, 2006, D. Popovici
% Copyright: Fraunhofer IAIS 2006 / Patent pending
% Revision 1, June 30, 2006, H. Jaeger
% Revision 2, Feb 23, 2007, H. Jaeger
% 
% Modefied: Junyuan Hong, 5/2015, jyhong836@gmail.com


	trained_lsm = lsm;
	switch trained_lsm.learningMode
		case 'offline_singleTimeSeries'
	        % trainInput and trainOutput each represent a single time series in
	        % an array of size sequenceLength x sequenceDimension
	        if strcmp(trained_lsm.type, 'twi_esn')
	            if size(trainInput,2) > 1
	                trained_lsm.avDist = ...
	                    mean(sqrt(sum(((trainInput(2:end,:) - trainInput(1:end - 1,:))').^2)));
	            else
	                trained_lsm.avDist = mean(abs(trainInput(2:end,:) - trainInput(1:end - 1,:)));
	            end
	        end
	        [stateCollection,internalState, lsm.simStateIndex] = ...
	        compute_lsm_statematrix(trainInput, trainOutput, trained_lsm, nForgetPoints);  % Pay attention to 'resetCsimStateFlag'
	        teacherCollection = compute_teacher(trainOutput, trained_lsm, nForgetPoints); 
	        if strcmp(trained_lsm.methodWeightCompute, 'bonus')
		        trained_lsm.outputWeights = feval(trained_lsm.methodWeightCompute, stateCollection, teacherCollection,trained_lsm.dt_out) ;
	        else
		        trained_lsm.outputWeights = feval(trained_lsm.methodWeightCompute, stateCollection, teacherCollection,val) ;
		    end
	    case  'offline_multipleTimeSeries'  
	    	error('ERROR: learning Mode "offline_multipleTimeSeries" is not implemented yet');
		case 'online'
	    	error('ERROR: learning Mode "online" is not implemented yet');
			
		otherwise
			error(['Undefined learning Mode: ' trained_lsm.learningMode]);
	end
	trained_lsm.trained = 1;

