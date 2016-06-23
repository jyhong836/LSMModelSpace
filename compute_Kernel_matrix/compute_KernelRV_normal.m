function [trainX,testX,trainerr,testerr] = compute_KernelRV_normal(datatrain,datatest,R_no,val,nForgetPoints, dt_out, SpikingInput)
% compute the weight matrix for dataset
% input:
%       datatrain -- training dataset
%       datatest  -- test dataset
%       R_no      -- number of reservior nodes
%       val       -- ridged regression parameter
%       nForgetPoints --inital washout period
% output:
%         trainX -- weight for training set 
%         testX -- weight for test set
%         trainerr -- training series fit error
%         testerr -- test series fit error
st = cputime; 
n_tr=length(datatrain);
n_te=length(datatest);

tX = datatrain{1};
dim = size(tX,1);
weightX = zeros(n_tr,(R_no)*dim);

trainerr = zeros(n_tr,1);

for i=1:n_tr
    fprintf('.');
    X = datatrain{i};
    [temp,trainerr(i)] = lsm_weight_normal(X,R_no,val,nForgetPoints, dt_out, SpikingInput);
    weightX(i,:) = reshape(temp,1,(R_no)*dim);

    if mod(i,50)==0,
       fprintf('\n');
    end
end

trainX = weightX;

testerr = zeros(n_te,1);
weightY = zeros(n_te,(R_no)*dim);
for i=1:n_te
    fprintf('.');
    Y = datatest{i};
    [temp, testerr(i)] = lsm_weight_normal(Y,R_no,val,nForgetPoints, dt_out, SpikingInput);
    weightY(i,:) = reshape(temp,1,(R_no)*dim);
    if mod(i,50)==0,
       fprintf('\n');
    end
end
 testX = weightY;
 
 time = cputime - st;
 disp(['used time: ' num2str(time)]);
 
 
 