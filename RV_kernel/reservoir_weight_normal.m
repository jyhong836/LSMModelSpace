function [data,error] = reservoir_weight_normal(X, R_no,val,nForgetPoints)
% Compute the related weight for data X
% X  is a time series data [N,d] = size(X)
% d is the dimension of the series
% N is the total number of points in X
% R_no is number of resevior nodes
% 
rand('state',2);
randn('state',2);

X = X';

[N,dim] = size(X);

nInputUnits = dim+1;
nInternalUnits = R_no;
nOutputUnits = dim;

inputScalingVect = ones(nInputUnits,1)*2;
inputShiftVect = zeros(nInputUnits,1)-0.5;
teacherScalingVect = ones(nOutputUnits,1)*2;
teacherShiftVect =zeros(nOutputUnits,1)-0.5;
feedbackScalingVect = ones(nOutputUnits,1)*0;

esn = generate_esn(nInputUnits, nInternalUnits, nOutputUnits,...
    'spectralRadius',0.9,'inputScaling',inputScalingVect,'inputShift',inputShiftVect, ...
    'teacherScaling',teacherScalingVect,'teacherShift',teacherShiftVect,'feedbackScaling',feedbackScalingVect, ...
    'type', 'plain_esn'); 

esn.internalWeights = esn.spectralRadius * esn.internalWeights_UnitSR;
esn.methodWeightCompute = 'wiener_hopf';

%%%% train the ESN
esn.noiseLevel = 0;

%% 
step = 1;
trainInputSequence1 = [X(1:N-step,:) ones(N-step,1)];
trainOutputSequence1 = X(1+step:N,:);
%% 
trainedEsn1 = train_esn(trainInputSequence1, trainOutputSequence1, esn, nForgetPoints,val) ;
[predictedTrainOutput1] = test_esn(trainInputSequence1, trainedEsn1,nForgetPoints) ;
trainError=compute_error(predictedTrainOutput1, trainOutputSequence1);

data1 = trainedEsn1.outputWeights;
data = data1(:,1:R_no);
% data = data1(:,end);

error = mean(trainError);



