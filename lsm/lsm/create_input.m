function [in_neus, in_syns] = create_input(Win, target_neus, varargin)
% CREATE_INPUT create the input neurons and connect to target neurons
% 
%	[in_neus, in_syns] = CREATE_INPUT(Win, target_neus)
%	Input:
%		Win		    - input weight, reservoirSize x inputSize
%		target_neus - handle of target neurons
%	Outut: 
%		in_neus     - handle of input neurons
%		in_syns		- handle of input synapse, wich will be connected to
%		target neurons
%	[in_neus, in_syns] = CREATE_INPUT(__, Name, Value)
%	Parameter:
%		Inoise      - noise of internel current
%		Spiking 	- if true, will use the spiking neuron ans synapse. 
%		default use analog ones
%		Bias 		- if 1, use bias at the end
%
% See also csim
%
% Author: Junyuan Hong, 5/2015, jyhong836@gmail.com 

resSize = size(Win, 1);
inSize  = size(Win, 2);
if resSize~=size(target_neus)
	error('ERROR: the size of Win and target_neus not march');
end

noise   = 0.00; % the amount of noise [e.g. nA^2]
spiking = 0; % use analog input
bias    = 0;

args = varargin;
nargs = length(args);
for i=1:2:nargs
	switch args{i}
		case 'Inoise', noise = args{i+1};
		case 'Spiking', spiking = args{i+1};
		case 'Bias', bias = args{i+1};
		otherwise error('the option does not exist'); 
	end
end


if ~spiking
	% 	in_neus = csim('create', 'AnalogInputNeuron', inSize);
	in_neus = csim('create', 'AnalogFeedbackNeuron', inSize);
	for io = 1:inSize
	    neu = in_neus(io);
	    csim('set', neu, 'feedback', 0); % feedback mode: 0, using externel current
	    csim('set',neu,'Vresting',0);
	    csim('set',neu,'Inoise',noise);
	end

	in_syns = zeros(resSize, inSize);
	for ii = 1:inSize
		in_syns(:, ii) = csim('create', 'StaticAnalogSynapse', resSize);
		ineu = in_neus(ii);
		for ir = 1:resSize
			syn = in_syns(ir, ii);
			csim('set',syn,'W',Win(ir, ii)); % weight
			csim('set',syn,'Inoise',noise);% noise

			csim('connect',target_neus(ir),ineu,syn);
		end
	end
else
	in_neus = zeros(inSize, 1);
	in_syns = zeros(resSize, inSize);

	% common component
	in_neus(1:inSize-bias) = csim('create', 'SpikingInputNeuron', inSize - bias);

	for ii = 1:(inSize - bias)
		in_syns(:, ii) = csim('create', 'StaticSpikingSynapse', resSize);
		ineu = in_neus(ii);
		for ir = 1:resSize
			syn = in_syns(ir, ii);
			csim('set',syn,'W',0.5); % weight
			csim('set',syn,'delay',0.001); % delay
			csim('set',syn,'tau',0.003); % tau_s

			csim('connect',target_neus(ir),ineu,syn);
		end
	end

	if bias==1
		% bias component
		in_neus(inSize-bias+1:inSize) = csim('create', 'AnalogInputNeuron', bias);
		for io = inSize-bias+1:inSize
		    neu = in_neus(io);
		    csim('set',neu,'Vresting',0);
		    csim('set',neu,'Inoise',noise);
		end

		for ii = (inSize - bias+1):inSize
			in_syns(:, ii) = csim('create', 'StaticAnalogSynapse', resSize);
			ineu = in_neus(ii);
			for ir = 1:resSize
				syn = in_syns(ir, ii);
				csim('set',syn,'W',Win(ir, ii)); % weight
				csim('set',syn,'Inoise',noise);% noise

				csim('connect',target_neus(ir),ineu,syn);
			end
		end
	end
end


