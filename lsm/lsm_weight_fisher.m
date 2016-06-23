function [gradient,stateCollection,trainError] = lsm_weight_fisher(datatrain, R_no,val,nForgetPoints, dt_out, SpikingInput)
% LSM_WEIGHT_FISHER compute the fisher score for datatrain
%
% See also lsm_weight_normal.
if nargin<5 || isempty(dt_out) || dt_out <= 0
    dt_out = 4e-3;
end
if nargin<6
    SpikingInput = 0;
end

rng(42);

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

if ~SpikingInput
    inputScalingVect = ones(nInputUnits,1)*2;
    inputShiftVect = zeros(nInputUnits,1)-0.5;
    teacherScalingVect = ones(nOutputUnits,1)*2;
    teacherShiftVect =zeros(nOutputUnits,1)-0.5;
    feedbackScalingVect = ones(nOutputUnits,1)*0;
else
    % ALERT: These settings will not be used when SpikingInput=true
    inputScalingVect    = ones(nInputUnits,1)*0.2; % ALERT: this is import for spiking Wout result.
    inputShiftVect      = zeros(nInputUnits,1);
    teacherScalingVect  = ones(nOutputUnits,1)*100;
    teacherShiftVect    = zeros(nOutputUnits,1);
    feedbackScalingVect = ones(nOutputUnits,1)*0;
end

%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%

%%%% train the LSM
lsm.noiseLevel = 0;
lsm = create_lsm_topology(lsm);

%% 
step = 1;

for i=1:n_tr
    fprintf('.');
    X = datatrain{i}';
    trainInputSequence = [X(1:N-step,:) ones(N-step,1)];
    trainOutputSequence = X(1+step:N,:);
    [trainedLSM,stateCollection] = train_lsm(trainInputSequence, trainOutputSequence, lsm, nForgetPoints,val);
    [predictedTrainOutput] = test_lsm(trainInputSequence, trainedLSM,nForgetPoints);
    if lsm.SpikingInput
        trainError = compute_spiketime_err(predictedTrainOutput, trainOutputSequence, lsm);
    else
        trainError = compute_error(predictedTrainOutput, trainOutputSequence);
    end
    data = trainedLSM.outputWeights;
    W = data(:,1:R_no);
    xt = stateCollection(:,1:R_no)';
    gradient(i,:) = predictedTrainOutput'*xt' - (W*xt)*xt';
    if mod(i,50)==0
        fprintf('\n');
    end
end



