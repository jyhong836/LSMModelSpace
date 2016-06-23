function [data,error] = reservoir_weight_sampling(X, R_no,L,val,nForgetPoints)
% sampling algorithms to compute the model distance 

rand('state',2);
randn('state',2);

%% Bootstrapping of time series 
num = 20;
shift_size = L;
Xseq = segmcirc(X,L,shift_size,num);
ind=bootrsp(1:num,1);
Xstart = Xseq(:,ind);
X = Xstart(:)';

%%
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

data = predictedTrainOutput1(:)';
error = mean(trainError);






