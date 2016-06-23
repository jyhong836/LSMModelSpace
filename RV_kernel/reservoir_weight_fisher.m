function [gradient,stateCollection,trainError] = reservoir_weight_fisher(datatrain, R_no,val,nForgetPoints)
%compute the fisher score for datatrain

rand('state',2);
randn('state',2);

n_tr=length(datatrain);
gradient = zeros(n_tr,R_no);

X = datatrain{1};
X = X';

if (nargin<3)
    R_no = 25;
end

[N,dim]= size(X);

nInputUnits = dim+1;
nInternalUnits = R_no;
nOutputUnits = dim;

inputScalingVect = ones(nInputUnits,1)*2;
inputShiftVect = zeros(nInputUnits,1)-0.5;
teacherScalingVect = ones(nOutputUnits,1)*2;
teacherShiftVect =zeros(nOutputUnits,1)-0.5;
feedbackScalingVect = ones(nOutputUnits,1)*0;

%%%%%%%%%%%%%%%%%%%%%%%
esn = generate_esn(nInputUnits, nInternalUnits, nOutputUnits,...
    'spectralRadius',0.9,'inputScaling',inputScalingVect,'inputShift',inputShiftVect, ...
    'teacherScaling',teacherScalingVect,'teacherShift',teacherShiftVect,'feedbackScaling',feedbackScalingVect, ...
    'type', 'plain_esn'); 
esn.internalWeights = esn.spectralRadius * esn.internalWeights_UnitSR;
esn.methodWeightCompute = 'wiener_hopf';
%%%%%%%%%%%%%%%%%%%%%%%

%%%% train the ESN
esn.noiseLevel = 0;

%% 
step = 1;

for i=1:n_tr
    fprintf('.');
    X = datatrain{i}';
    trainInputSequence = [X(1:N-step,:) ones(N-step,1)];
    trainOutputSequence = X(1+step:N,:);
    [trainedEsn,stateCollection] = train_esn(trainInputSequence, trainOutputSequence, esn, nForgetPoints,val);
    [predictedTrainOutput] = test_esn(trainInputSequence, trainedEsn,nForgetPoints);
    trainError = compute_error(predictedTrainOutput, trainOutputSequence);
    data = trainedEsn.outputWeights;
    W = data(:,1:R_no);
    xt = stateCollection(:,1:R_no)';
    gradient(i,:) = predictedTrainOutput'*xt' - (W*xt)*xt';
    if mod(i,50)==0
        fprintf('\n');
    end
end



