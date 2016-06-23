function ret_lsm = create_lsm_topology(lsm)
% CREATE_LSM_TOPOLOGY create the neurons and synapse connections used by csim
% 

	ret_lsm = lsm;
	[ret_lsm.res_neus, ret_lsm.res_syns, ret_lsm.leaky_syns] = create_network(ret_lsm.internalWeights,...
		ret_lsm.leakage, 'Inoise', ret_lsm.noiseLevel);

    [ret_lsm.in_neus, ret_lsm.in_syns] = create_input(ret_lsm.inputWeights, ret_lsm.res_neus,...
    	'Inoise', ret_lsm.noiseLevel, 'Spiking', lsm.SpikingInput, ...
		'Bias', 1);

    % TODO: remove the feedback?
	[ret_lsm.fb_neus, ret_lsm.fb_syns] = create_input(ret_lsm.feedbackWeights, ret_lsm.res_neus, ...
		'Inoise', ret_lsm.noiseLevel, 'Spiking', ret_lsm.SpikingInput);

	% % recoders
	% disp('create recorders...');
	% % reservoir recorders
	% lsm.res_vm_recoder = csim('create', 'MexRecorder');
	% csim('set', lsm.res_vm_recoder, 'dt', lsm.dt_out);
	% csim('set', lsm.res_vm_recoder, 'commonChannels', 1); % output in Matrix format
	% csim('connect', lsm.res_vm_recoder, lsm.res_neus, 'Vm');
	if lsm.SpikingInput
		ret_lsm.res_sp_recorder = csim('create', 'MexRecorder');
		csim('connect', ret_lsm.res_sp_recorder, ret_lsm.res_neus, 'spikes');
	end


