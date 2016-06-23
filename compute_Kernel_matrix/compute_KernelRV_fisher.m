function [gradient_tr,gradient_te] = compute_KernelRV_fisher(datatrain,datatest,R_no,val,nForgetPoints, dt_out, SpikingInput)
%compute the fisher score for training and test datasets.
st = cputime;

% gradient_tr = reservoir_weight_fisher(datatrain, R_no,val,nForgetPoints);
% gradient_te = reservoir_weight_fisher(datatest, R_no,val,nForgetPoints);

gradient_tr = lsm_weight_fisher(datatrain, R_no,val,nForgetPoints, dt_out, SpikingInput);
gradient_te = lsm_weight_fisher(datatest, R_no,val,nForgetPoints, dt_out, SpikingInput);

time = cputime - st

