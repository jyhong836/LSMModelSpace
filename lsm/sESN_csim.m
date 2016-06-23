% This is an example of spiking ESN based on 'csim'.
% This example is different from we used in model kernel.
%
% See also csim.
%
% Author Junyuan Hong, 2015-5, jyhong836@gmail.com

if ~exist('cleared','var') || ~cleared; 
    clear all;
    if exist('./exp_conf/exp_conf_1.mat', 'file')
        load ./exp_conf/exp_conf_1.mat;
    end
end

init_env

% settings
if ~exist('dc_enabled', 'var');   
	dc_enabled   = false;   
end;
if ~exist('in_out_connect', 'var'); 
	in_out_connect = false; 
end;
if dc_enabled
    disp('* dc is enabled');
end
if in_out_connect
    disp('* in out is connected');
end

%
% load necessary parameters
%
load_parameter;

% 
% create reservoir parameters: W, Win, and sizes
% 
create_reservoir;

%
% create topology, including input, reservoir and output 
% layer network
%
create_topology;

%
% create recorder of data for ploting
%
create_recorder;

%
% simulate with the train data input
%
train_simulate;

%% plot the output
%
figure(fig_n); fig_n = fig_n+1; clf reset;

% membrance voltage
subplot(2,1,1); cla reset;
ldt=dt_out;
t=ldt:ldt:Tsim;
plot(t,res_vm.data(1 ,initLen+1:trainLen),'b'); hold on
plot(t,res_vm.data(10,initLen+1:trainLen),'g'); hold on
axis tight
set(gca,'Xlim',[0 Tsim]);
legend('neuron 1','neuron 10');
title('membrane voltage');
hold off;
clear ldt

subplot(2,1,2); 
plot(t, res_vm.data(:,initLen+1:trainLen)');
axis tight
xlim([0,Tsim]);
title('membrance voltage');
clear t;

% % post-synaptic current
% subplot(2,1,2); cla reset;
% ldt=csim('get',res_psc_recorder,'dt');
% t=ldt:ldt:Tsim;
% plot(t,res_psc.channel(1).data(initLen+1:trainLen),'k'); hold on
% plot(t,res_psc.channel(10).data(initLen+1:trainLen),'b'); hold on
% plot(t,res_psc.channel(100).data(initLen+1:trainLen),'g'); hold on
% plot(t,res_psc.channel(200).data(initLen+1:trainLen),'r'); hold on
% axis tight
% set(gca,'Xlim',[0 Tsim]);
% legend('syn 1','syn 10','syn 100','syn 200');
% xlabel('time [sec]');
% title('post-synaptic current');
% hold off;

%
%% train the Wout matrix with Linear Regression
%
train_wout;

%
%% let the network run to generate signal
%
generate_signal;

Yt = data(trainLen+1:trainLen+testLen); % target
% plot
% figure(3);
% Yt_fb = [inp_vm.channel(:).data];
% plot([Yt', Yt_fb']);
% legend('target', 'predicted');
figure(fig_n); fig_n = fig_n+1;
Yt_sim = Yt_sim';
plot([Yt, Yt_sim]);
legend('target','predicted');
mse_test = sum((Yt_sim - Yt).^2)./size(Yt,2);


