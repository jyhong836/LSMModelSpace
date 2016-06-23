function err = compute_spiketime_err (estimatedOutput, correctOutput, lsm)
% compute_spiketime_err computer spike time diff between two spike train
%	err = COMPUTE_SPIKETIME_ERR (estimatedOutput, correctOutput, lsm)
%	The first n points of estimatedOutput and correctOutput 
%	will be compared, n is the spike number of correctOutput.
%
%	See also vector2spikes.
%	
%	Author: Junyuan Hong, 2015-05-28, jyhong836@gmail.com

if lsm.nOutputUnits > 1
	error(['nOutputUnits > 1 is not supported yet.']);
end

nEstimatePoints = size(estimatedOutput,1) ; 
nForgetPoints = size(correctOutput,1) - nEstimatePoints ; 
correctOutput = correctOutput(nForgetPoints+1:end,:) ; 


corr_train = vector2spikes(correctOutput, lsm.dt_out);
esti_train = vector2spikes(estimatedOutput, lsm.dt_out);

ncr = size(corr_train, 1);
nes = size(esti_train, 1);
if ncr ~= nes
	warning(['the estimatedOutput(' ...
		num2str(nes) ...
		') and correctOutput length('...
		num2str(ncr)...
		') not match, the spike time '...
		'error result may not be  correct.']);
	n = max(ncr, nes);
	corr_train_ = zeros(n, 1);
	esti_train_ = zeros(n, 1);
	corr_train_(1:ncr) = corr_train;
	esti_train_(1:nes) = esti_train;
	corr_train = corr_train_;
	esti_train = esti_train_;
else
	n = ncr;
end
meanerror = (sum(abs(esti_train - corr_train)))/n;

err = meanerror;

