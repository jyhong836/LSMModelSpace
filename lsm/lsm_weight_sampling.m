function [data,error] = lsm_weight_sampling(X, R_no,L,val,nForgetPoints, dt_out, SpikingInput)
% sampling algorithms to compute the model distance 
if nargin<6 || isempty(dt_out) || dt_out <= 0
    dt_out = 4e-3;
end
if nargin<6
	SpikingInput = 0;
end

rng(42);

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

if ~SpikingInput
	inputScalingVect = ones(nInputUnits,1)*2;
	inputShiftVect = zeros(nInputUnits,1)-0.5;
	teacherScalingVect = ones(nOutputUnits,1)*2;
	teacherShiftVect =zeros(nOutputUnits,1)-0.5;
	feedbackScalingVect = ones(nOutputUnits,1)*0;
else
	inputScalingVect    = ones(nInputUnits,1)*0.2;
	inputShiftVect      = zeros(nInputUnits,1);
	teacherScalingVect  = ones(nOutputUnits,1)*100;
	teacherShiftVect    = zeros(nOutputUnits,1);
	feedbackScalingVect = ones(nOutputUnits,1)*0;
end

lsm = generate_lsm(nInputUnits, nInternalUnits, nOutputUnits,...
    'spectralRadius',0.9,'inputScaling',inputScalingVect,'inputShift',inputShiftVect, ...
    'teacherScaling',teacherScalingVect,'teacherShift',teacherShiftVect,'feedbackScaling',feedbackScalingVect, ...
    'type', 'plain_lsm', 'dt_out', dt_out, 'SpikingInput', SpikingInput); 

lsm.internalWeights = lsm.spectralRadius * lsm.internalWeights_UnitSR;
if ~SpikingInput
	lsm.methodWeightCompute = 'wiener_hopf';
else
	lsm.methodWeightCompute = 'bonus';
end

%%%% train the LSM
lsm.noiseLevel = 0;
lsm = create_lsm_topology(lsm);

%% 
step = 1;
trainInputSequence1 = [X(1:N-step,:) ones(N-step,1)];
trainOutputSequence1 = X(1+step:N,:);
%% 
trainedLSM1 = train_lsm(trainInputSequence1, trainOutputSequence1, lsm, nForgetPoints,val) ;
[predictedTrainOutput1] = test_lsm(trainInputSequence1, trainedLSM1,nForgetPoints) ;
if lsm.SpikingInput
	trainError = compute_spiketime_err(predictedTrainOutput1, trainOutputSequence1, lsm);
else
	trainError = compute_error(predictedTrainOutput1, trainOutputSequence1);
end

data = predictedTrainOutput1(:)';
error = mean(trainError);






