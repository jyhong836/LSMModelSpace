%
% train Wout using membrance potential
%
% X = reshape([rdout_psc.channel(:).data], timeLen, resSize)'; % psc as output state
% X = reshape([rdout_vm.channel(:).data], timeLen, resSize)'; % vm as output state
% X = reshape([res_vm.channel(:).data], trainLen, resSize); % vm as output state
X = res_vm.data(:,initLen+1:trainLen)';
wout_sz = resSize;
if dc_enabled && in_out_connect
	X = [data_dc(initLen+1:trainLen),trainInputData,X]';
	wout_sz = wout_sz + 1 + inSize;
elseif dc_enabled
	X = [data_dc(initLen+1:trainLen),X]';
	wout_sz = wout_sz + 1;
elseif in_out_connect
	X = [trainInputData,X]';
	wout_sz = wout_sz + inSize;
else
	X = X';
end
	
X_T = X';
Wout = Yt*X_T /(X*X_T + reg*eye(wout_sz));
clear wout_sz X_T;

%% plots
% compare result with input
figure(fig_n); fig_n = fig_n+1;
% Yt_fb = [inp_vm.channel(:).data];
% plot([(Wout*X)', Yt_fb']);
% Yt = [inp_vm.channel(:).data];
plot([(Wout*X)', Yt']);
legend('Wout*x', 'Yt');

% plot Wout
figure(fig_n); fig_n = fig_n+1;
bar( Wout' )
title('Output weights W^{out}');

%% calcuate min squire error
mse = sum((Wout*X - Yt).^2)./size(Yt,2);
disp(['MSE = ' num2str(mse)]);

