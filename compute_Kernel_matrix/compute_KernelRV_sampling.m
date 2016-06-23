function [trainX,testX,trainerr,testerr] = compute_KernelRV_sampling(datatrain,datatest,R_no,L,val,nForgetPoints, dt_out, SpikingInput)
%compute the kernel matrix using sampling
st = cputime;
n_tr=length(datatrain);
n_te=length(datatest);

tX = datatrain{1};

dim = size(tX,1);
% weightX = zeros(n_tr,(R_no)*dim);
ndim =  (L*20 -50-1);%*dim;
weightX = zeros(n_tr,ndim);
trainerr = zeros(n_tr,1);

for i=1:n_tr
    fprintf('.');
    X = datatrain{i};
    [temp,trainerr(i)] = lsm_weight_sampling(X,R_no,L,val,nForgetPoints, dt_out, SpikingInput);
    weightX(i,:) = temp;

    if mod(i,50)==0,
       fprintf('\n');
    end
end


trainX = weightX;

testerr = zeros(n_te,1);
weightY = zeros(n_te,ndim);

for i=1:n_te
    fprintf('.');
    Y = datatest{i};
    [temp, testerr(i)] = lsm_weight_sampling(Y,R_no,L,val,nForgetPoints, dt_out, SpikingInput);
    weightY(i,:) = temp;
    
    if mod(i,50)==0,
       fprintf('\n');
    end
end

 testX = weightY;
 
 time = cputime - st
 