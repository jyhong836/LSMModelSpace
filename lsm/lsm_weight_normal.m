function [ data,error ] = lsm_weight_normal( X, R_no, val, nForgetPoints, dt_out, SpikingInput )
%LSM_WEIGHT_NORMAL Compute the related weight for data X
%  [ data,error ] = ...
%   LSM_WEIGHT_NORMAL( X, R_no, val, nForgetPoints, dt_out, SpikingInput )
%  input:
%    X             - a time series data [N,d] = size(X)
%    d             - the dimension of the series
%    N             - the total number of points in X
%    R_no          - number of resevior nodes
%    val           - ridged regression parameter
%    nForgetPoints - inital washout period
%	 dt_out        - inpput and output signal time step length, for spiking
%	, recommond you to use 1e-3
%	 SpikingInput  - X is spiking train
%  output:
%    data          - Wout matrix
%    error         - test error of predicted series and target series
%
%  See also: generate_lsm, train_lsm, test_lsm, 

% TODO: nForgetPoints should be reset when use SpikingInput or not?

if nargin<5 || isempty(dt_out) || dt_out <= 0
    dt_out = 4e-3;
end
if nargin<6
	SpikingInput = 0;
end

rng(42);

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
	% ALERT: These settings will not be used when SpikingInput=true
	inputScalingVect    = ones(nInputUnits,1)*0.2; % ALERT: this is import for spiking Wout result.
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

%%%% train the ESN
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

data1 = trainedLSM1.outputWeights;
data = data1(:,1:R_no);
% data = data1(:,end);

error = mean(trainError);

csim('set', 'verboseLevel', 0);
csim('destroy');

% % TODO: remove this codes when finish plot
% dt = lsm.dt_out;
% if lsm.SpikingInput
%     spikeOutput = vector2spikes(predictedTrainOutput1,dt);
%     spikeOutput1 = vector2spikes(trainOutputSequence1(nForgetPoints+1:end),dt);
%     len = length(spikeOutput);
%     figure(1);clf reset;
%     for i=1:len
%         line([spikeOutput(i), spikeOutput(i)], [0,1],'color','b', 'LineWidth',1.5);
%         line([spikeOutput1(i), spikeOutput1(i)], [0,1],'color','r','LineWidth',1.5);
%     end
%     xlabel time/sec
%     legend('predicted ouput', 'target output');
% else
%     plot(dt:dt:(dt*length(predictedTrainOutput1)),...
%         [predictedTrainOutput1,trainOutputSequence1(nForgetPoints+1:end)]);
%     xlabel time/second
%     axis tight
% end

end

