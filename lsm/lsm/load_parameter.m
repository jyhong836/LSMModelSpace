% simulation parameters
if ~exist('dt_sim', 'var'); dt_sim  = 1e-4; end  % integration time step [sec]
disp(['dt_sim = ' num2str(dt_sim)]);
% Tsim    = 0.6;   % simulation time [sec]
if ~exist('dt_out', 'var'); dt_out  = 0.005; end % intervals at which VMs and PSCs are recorded [sec]
disp(['dt_out = ' num2str(dt_out)]);
% noise   = 0.00;   % the amount of noise [e.g. nA^2]
mySeed  = 314159;

csim('destroy'); % free handles created by csim
csim('set','dt',dt_sim);
csim('set','randSeed',mySeed);

% data defines
trainLen = 2000;
testLen  = 2000;
initLen  = 100;

% load the data
data = load('dataset/MackeyGlass_t17.txt');
if dc_enabled
    if ~exist('dc_v', 'var'); dc_v = 1.0; end
    disp(['dc_v = ' num2str(dc_v)]);
	data_dc = dc_v*ones(size(data));
end

% plot some of it
figure(10);
plot(data(1:1000));
title('A sample of data');

% % allocated memory for the design (collected states) matrix
% X = zeros(1+inSize+resSize,trainLen-initLen);
% set the corresponding target matrix directly
% traget output
Yt = data(initLen+2:trainLen+1)'; 
timeLen = trainLen - initLen; % = size(Yt,2);
Tsim = timeLen*dt_out; % train simulation time
Tinit = initLen*dt_out;
Ttest = testLen*dt_out;

if ~exist('inputOpt', 'var')
	inputOpt.Model = 'Generic';
end
if ~isfield(inputOpt, 'Type')
%     warning(['WARN: no define input type']);
    inputOpt.Type = 'Analog';
end

disp(['model type:' inputOpt.Model]);
% seperate the data 
if strcmp(inputOpt.Model, 'Generic')
	% generic model
	initInputData  = data(1:initLen);
	trainInputData = data(initLen+1:trainLen);
	testInputData  = data(trainLen+1:trainLen+testLen);
	testInputData(2:end) = 0;
elseif strcmp(inputOpt.Model, 'Drive')
	% drive model
	disp(['input type:' inputOpt.Type]);
	if strcmp(inputOpt.Type, 'Analog')
		t = dt_out:dt_out:(Tinit+Tsim+Ttest);
		if ~isfield(inputOpt, 'func')
			inputOpt.func = @(x)1+sin(2*pi*x);
		end
		driveData = inputOpt.func(t)';

		initInputData  = driveData(1:initLen);
		trainInputData = driveData(initLen+1:trainLen);
		testInputData  = driveData(trainLen+1:trainLen+testLen);
	elseif strcmp(inputOpt.Type, 'Spiking')
		if in_out_connect
			warning(['WARN: in_out_connect is enabled, which is not allowed when input type is Spiking. Force to disabled']);
			in_out_connect = false;
		end
		if ~isfield(inputOpt, 'func')
			inputOpt.func = @(x1,x2)x1:1e-2:x2;
		end
		initInputData  = inputOpt.func(dt_out, Tinit)';
		trainInputData = inputOpt.func(Tinit, Tinit+Tsim)';
		testInputData  = inputOpt.func(Tinit+Tsim, Tinit+Tsim+Ttest)';
	else
		error(['ERROR: unknow input type: ' inputOpt.Type]);
	end
else
	error(['ERROR: unknow model type: ' inputOpt.Model]);
end

% size define
inSize  = 1; 
outSize = 1;
if ~exist('resSize', 'var'); resSize = 200; end
disp(['resSize = ' num2str(resSize)]);
if ~exist('leaky_a', 'var'); leaky_a = 0.3; end % leaking rate
disp(['leaky_a = ' num2str(leaky_a)]);

% figure number
fig_n = 1;

% regression coefficient for train Wout
if ~exist('reg', 'var'); reg = 5;  end
disp(['reg = ' num2str(reg)]);


