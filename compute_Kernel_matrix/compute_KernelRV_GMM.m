function [Ktrain,Ktraintest] = compute_KernelRV_GMM(datatrain,datatest,R_no,val,nForgetPoints, dt_out, SpikingInput)
% compute kernel matrix for training and test dataset
% compute the weight matrix for dataset
% input:
%       datatrain -- training dataset
%       datatest  -- test dataset
%       R_no      -- number of reservior nodes
%       val       -- ridged regression parameter
%       nForgetPoints --inital washout period
% output:
%         KtrainX -- kernel matrixfor training set 
%         Ktraintest -- kernel for test set
st = cputime;
[Ktrain,Ktraintest] = lsm_weight_GMM(datatrain,datatest,R_no,val,nForgetPoints, dt_out, SpikingInput);
% [Ktrain,Ktraintest] = reservoir_weight_GMM(datatrain,datatest,R_no,val,nForgetPoints);

% %normalize
max_val = max(max(Ktrain));
Ktrain = Ktrain/max_val;
Ktraintest = Ktraintest/max_val;
Ktraintest = Ktraintest';

time = cputime - st
