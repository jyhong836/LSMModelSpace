% Set up the input
if strcmp(inputOpt.Type, 'Analog')
    inp(1).spiking = 0;
    inp(1).idx	   = in_neus(1);
    inp(1).dt 	   = dt_out;
    inp(1).data    = [initInputData', trainInputData'];
elseif strcmp(inputOpt.Type, 'Spiking')
    inp(1).spiking = 1;
    inp(1).idx	   = in_neus(1);
    inp(1).dt 	   = 0;
    inp(1).data    = [initInputData', trainInputData'];
end

if dc_enabled
    inp(2).spiking = 0;
    inp(2).idx 	   = in_neus(2);
    inp(2).dt      = dt_out;
    inp(2).data    = data_dc';
end

% init simulation states
disp('init simulation sates...');
csim('reset');
csim('simulate',Tinit,inp);
disp('done');

%% run the simulation
%
disp('simulating...');
tic
csim('simulate',Tsim,inp);
% csim('simulate',Tsim/3,inp);
% csim('simulate',Tsim/3,inp);
% get results
res_vm = csim('get',res_vm_recoder,'traces');
% res_psc = csim('get',res_psc_recorder,'traces');
% res_spikes = csim('get',res_sp_recorder,'traces');
% rdout_psc = csim('get',rdout_psc_recorder,'traces');
% rdout_vm = csim('get',rdout_vm_recoder,'traces');
% inp_vm = csim('get', inp_vm_recorder, 'traces');
toc
disp('done');

