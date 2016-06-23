function generate_lsm_state_data(varargin)
% GENERATE_LSM_STATE_DATA  Generate LSM internal state data.
%	Default save generated data to 'datasets/lsm_InterState_DATANAME.mat'.
%	
%	GENERATE_LSM_STATE_DATA('parameter', value, ...)
%	parameter:
%		dataIndex   - dataset.training{dataIndex} will be
%			used as input.
%		dataName    - specify input data set name.
%		R_no        - Resevoir size, or internel neuron 
%			number.
%		ParamChoice - Use lsm_weight_normal 'Scaling' and 
%			'Shift' parameter settings.
%		saveParamFlag - if true, will save the parameters 
%			and plot figures.
%		nForgetPoints - default is 50.
%
%	Example:
%		generate_lsm_state_data('dataName','PreAdiac', ...
%			'ParamChoice', 1, 'saveParamFlag', true, ...
%			'nForgetPoints', 100);
%
%	See also: create_lsm_topology, compute_lsm_statematrix.
%	(C) 2015, Junyuan Hong (jyhong836@gmail.com)
%

%
%% init parameters 
%
% if nargin<1 || strcmp(varargin{1}, 'help')
% 	help generate_lsm_state_data
% 	return
% end

dataIndex = 1; % dataset.training{dataIndex} will be used as input
dataName = 'PreBeef'; % input data set name
R_no = 100; % Resevoir size, or internel neuron number
paramchoice = 1;
nForgetPoints = 50;
saveParamFlag = false;

args = varargin;
nargs = length(args);
for i=1:2:nargs
	switch lower(args{i})
		case 'dataname', dataName = args{i+1};
		case 'dataindex', dataIndex = args{i+1};
		case 'r_no', R_no = args{i+1};
		case 'paramchoice', paramchoice = args{i+1};
		case 'saveparamflag', saveParamFlag = args{i+1};
		case 'nforgetpoints', nForgetPoints = args{i+1};
		otherwise
			error(['the option("' args{i} '") not exist']); 
	end
end

savefilename = fullfile('datasets', ['lsm_InterState_' dataName '.mat']);
if ~exist('datasets', 'dir')
	mkdir('datasets');
end


%
%% init path
%
run('../initpath')


%
%% basic settings
%
data = load(dataName);
X = data.training{dataIndex};

rand('state',2);
randn('state',2);
% rand('seed', 42);

dt_out = 4e-3;
X = X';

[N,dim] = size(X);

nInputUnits = dim+1;
nInternalUnits = R_no;
nOutputUnits = dim;

switch paramchoice
	case 1
		disp('** Use reservoir_weight_normal settings');
		inputScalingVect = ones(nInputUnits,1)*2;
		inputShiftVect = zeros(nInputUnits,1)-0.5;
		teacherScalingVect = ones(nOutputUnits,1)*2;
		teacherShiftVect =zeros(nOutputUnits,1)-0.5;
		feedbackScalingVect = ones(nOutputUnits,1)*0;
	case 2
		disp('** Use lsm_weight_normal settings');
		inputScalingVect = ones(nInputUnits,1)*2;
		inputShiftVect = zeros(nInputUnits,1);
		teacherScalingVect = ones(nOutputUnits,1)*2;
		teacherShiftVect =zeros(nOutputUnits,1);
		feedbackScalingVect = ones(nOutputUnits,1)*1;
	otherwise
		error(['Unknown parameter choice: ' num2str(paramchoice)]);
end

lsm = generate_lsm(nInputUnits, nInternalUnits, nOutputUnits,...
    'spectralRadius',0.9,'inputScaling',inputScalingVect,'inputShift',inputShiftVect, ...
    'teacherScaling',teacherScalingVect,'teacherShift',teacherShiftVect,'feedbackScaling',feedbackScalingVect, ...
    'type', 'plain_lsm', 'dt_out', dt_out); 

lsm.internalWeights = lsm.spectralRadius * lsm.internalWeights_UnitSR;
lsm.methodWeightCompute = 'wiener_hopf';

lsm.noiseLevel = 0;
lsm = create_lsm_topology(lsm);


%
%% Simulate
%
step = 1;
trainInputSequence1 = [X(1:N-step,:) ones(N-step,1)];
trainOutputSequence1 = X(1+step:N,:);

[stateCollection, internalState, lsm.simStateIndex] = ...
    compute_lsm_statematrix(trainInputSequence1, trainOutputSequence1, lsm, nForgetPoints);
csim('destroy');


%
%% Save 
%
stateCollection = stateCollection(1:end-1,:); % FIXME: the reason why minus 1 has not been proposed yet!
save(savefilename, 'stateCollection');

if saveParamFlag
	saveDir = fileparts(savefilename);
	saveDir = fullfile(saveDir, 'params');
	if ~exist(saveDir, 'dir')
		mkdir(saveDir);
	end
	save(fullfile(saveDir, [dataName '_param']), 'dataName', 'dataIndex', 'R_no', 'paramchoice', 'nForgetPoints');
	figure(1);
	plot(stateCollection);
	title([dataName ' states R\_no(' num2str(R_no) ')']);
	ylabel('membrace potential');
    xlim([1, size(stateCollection,1)]);
	saveas(gcf, fullfile(saveDir, [dataName '_state']), 'png');
	saveas(gcf, fullfile(saveDir, [dataName '_state']));
	figure(2);
	plot(X);
	title(['input signal: ' dataName]);
end

