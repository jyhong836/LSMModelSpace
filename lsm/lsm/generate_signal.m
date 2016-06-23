%% genenrate signals
% update_readout(Wout, readouts, 0, in_neus); % disable feedback for step-sim
% % Set up the input
% inp(1).spiking = 0;
% inp(1).idx	   = in_neus(1);
% inp(1).dt 	   = dt_out;
% inp(1).data    = Yt;
% run the simulation
%
% csim('reset');
% Set up the input
Yt_sim = data(trainLen+1:trainLen+testLen)';
Yt_sim(2:end) = 0;
inp(1).data    = [inp(1).data,testInputData'];
% csim('simulate', dt_out, inp);

S=whos;disp(['used memory: ' num2str(sum([S.bytes],2)/1024/1204) ' Mbytes']);

tic
disp('contitue to simulating...');
if strcmp(inputOpt.Model, 'Generic')
	enable_vm_rc = 0;
	csim('set',res_vm_recoder,'enabled',enable_vm_rc);

	if dc_enabled && in_out_connect
		for ti = 2:testLen
			csim('simulate',dt_out, inp);
		    
		    Yt_sim(ti) = Wout*[dc_v;Yt_sim(ti-1);csim('get',res_neus,'Vm')'];
		    
		    inp(1).data(trainLen+ti) = Yt_sim(ti);
		end
	elseif dc_enabled
		for ti = 2:testLen
			csim('simulate',dt_out, inp);
		    
		    Yt_sim(ti) = Wout*[dc_v;csim('get',res_neus,'Vm')'];
		    
		    inp(1).data(trainLen+ti) = Yt_sim(ti);
		end
	elseif in_out_connect
		for ti = 2:testLen
			csim('simulate',dt_out, inp);
		    
		    Yt_sim(ti) = Wout*[Yt_sim(ti-1);csim('get',res_neus,'Vm')'];
		    
		    inp(1).data(trainLen+ti) = Yt_sim(ti);
		end
	else
		for ti = 2:testLen
			csim('simulate',dt_out, inp);
		    
		    Yt_sim(ti) = Wout*csim('get',res_neus,'Vm')';
		    
		    inp(1).data(trainLen+ti) = Yt_sim(ti);
		end
	end
	clear ti;
	if enable_vm_rc==1
		Xsim = res_vm.data(:,trainLen+1:trainLen+testLen)';
	end
elseif strcmp(inputOpt.Model, 'Drive')
	enable_vm_rc = 1;
	csim('simulate', Ttest, inp);
    res_vm = csim('get', res_vm_recoder, 'traces');
	Xsim = res_vm.data(:,trainLen+1:trainLen+testLen)';
    if dc_enabled && in_out_connect
        Xsim = [data_dc(trainLen+1:trainLen+testLen),testInputData,Xsim]';
    elseif dc_enabled
        Xsim = [data_dc(trainLen+1:trainLen+testLen),Xsim]';
    elseif in_out_connect
        Xsim = [testInputData,Xsim]';
    else
        X = X';
    end
	Yt_sim = Wout*Xsim;
end


%     Yt_sim(ti) - Yt(ti)
% 	inp(1).data = Yt;
% end
% % csim('simulate',Tsim/3,inp);
% % csim('simulate',Tsim/3,inp);
% % get results
% res_vm = csim('get',res_vm_recoder,'traces');
% res_psc = csim('get',res_psc_recorder,'traces');
% res_spikes = csim('get',res_sp_recorder,'traces');
% % rdout_psc = csim('get',rdout_psc_recorder,'traces');
% rdout_vm = csim('get',rdout_vm_recoder,'traces');
% inp_vm = csim('get', inp_vm_recorder, 'traces');
toc
disp('done');

S=whos;disp(['used memory: ' num2str(sum([S.bytes],2)/1024/1204) ' Mbytes']);
clear S



