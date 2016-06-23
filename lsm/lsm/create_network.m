function [csim_neus, csim_syns, leaky_syns] = create_network(W, leaky_a, varargin)
% CREATE_NETWORK: create the reservoir network
%	W - connection weight matrix
%	csim_neus - LIF Neurons
%	csim_syns - Dynamic Spiking Synapse

	sz1 = size(W, 1);
	sz2 = size(W, 2);
	if sz1 ~= sz2
		error('ERROR: W is not squire matrix, sz1~=sz2');
	end
	neuSize = sz1; % size of neuron
    
    noise   = 0.00;   % the amount of noise [e.g. nA^2]
    
	args = varargin;
	nargs = length(args);
	for i=1:2:nargs
		switch args{i}
			case 'Inoise', noise = args{i+1};
			otherwise error('the option does not exist'); 
		end
	end

	% create leaky integrate and fire neurons
	csim_neus = csim('create', 'LifNeuron', neuSize)';
	for in = 1:neuSize
		neu = csim_neus(in);
		csim('set',neu,'Vthresh',0.015);  % threshold  
		csim('set',neu,'Trefract',0.003); % refractory period
		csim('set',neu,'Cm',0.03);        % tau_m = Cm * Rm
		csim('set',neu,'Vreset',0.005);   % V_reset
		csim('set',neu,'Iinject',0.002);  % I_back
		csim('set',neu,'Vinit',0.001);    % V_init
		csim('set',neu,'Rm',1.0);
		csim('set',neu,'Inoise',noise);
		csim('set',neu,'Vresting',0);
		% another way of parameter settings
		% csim('set',neu,'Vthresh',0.01,'Trefract',0.002,'Cm',0.05,'Vreset',0.0,'Iinject',0.0,'Vinit',0.0,'Rm',1.0,'Inoise',noise,'Vresting',0); 
	end

	% set up the connections
	csim_syns = zeros(neuSize, neuSize, 'uint32');
	for i1 = 1:neuSize
		% csim_syns(i1, :) = csim('create', 'DynamicSpikingSynapse', neuSize);
		for i2 = 1:neuSize
			if abs(W(i1, i2))>1e-5 % connected
				syn = csim('create', 'DynamicSpikingSynapse');
				csim_syns(i1, i2) = syn;
				csim('set',syn,'W',W(i1, i2));% weight
				if W(i1, i2)>0 % excitatory
					csim('set',syn,'delay',0.001);% delay
					csim('set',syn,'tau',0.003);% tau_s
					csim('set',syn,'U',0.2);% U
					csim('set',syn,'D',1.0);% D
					csim('set',syn,'F',0.3);% F
					csim('set',syn,'u0',0.2);
	            elseif W(i1, i2)<0 % inibitory
					csim('set',syn,'delay',0.0);% delay
					csim('set',syn,'tau',0.03);% tau_s
					csim('set',syn,'U',0.7);% U
					csim('set',syn,'D',0.1);% D
					csim('set',syn,'F',1.0);% F
					csim('set',syn,'u0',0.7);
				end
				csim('set',syn,'r0',1.0);

				csim('connect',csim_neus(i1),csim_neus(i2),syn);
			end
		end
	end

	% connect back
	leaky_syns = csim('create', 'DynamicSpikingSynapse', neuSize);
	for ii = 1:neuSize
		syn = leaky_syns(ii);
		csim('set',syn,'W',1/leaky_a-1);% weight
		% excitatory
		csim('set',syn,'delay',0.001);% delay
		csim('set',syn,'tau',0.003);% tau_s
		csim('set',syn,'U',0.2);% U
		csim('set',syn,'D',1.0);% D
		csim('set',syn,'F',0.3);% F
		csim('set',syn,'u0',0.2);
		csim('set',syn,'r0',1.0);

		csim('connect',csim_neus(ii),csim_neus(ii),syn);
	end

