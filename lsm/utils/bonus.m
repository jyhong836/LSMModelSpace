function outputWeights = bonus(stateCollectMat, teachCollectMat, dt, tau)
% BONUS bonus algorithm
%	outputWeights = BONUS(stateCollectMat, teachCollectMat, val)
%	input:
%	stateCollectMat - matrix of size nStatePoints x nInternalUnits
%	teachCollectMat - matrix of size nTeachPoints x nOutputUnits
%	output:
%	outputWeights - matrix of size nOutputUnits x nInternalUnits
%	
%	See also spikes2exp, vector2spikes
%	
%	Author: Junyuan Hong, 2015-05-27, jyhong836@gmail.com

if nargin < 4
%     tau = 2*dt;
	tau = 0.001; %3*dt;% % TODO: the tau should be set
end

nTeachPoints   = size(teachCollectMat, 1);
nOutputUnits   = size(teachCollectMat, 2);
nStatePoints   = size(stateCollectMat, 1);
nInternalUnits = size(stateCollectMat, 2);
if nTeachPoints ~= nStatePoints
	error(['Teach points should be the same as state points.']);
end
bon = zeros(nTeachPoints, nOutputUnits);
Tsim = dt*nTeachPoints;
for i = 1:nOutputUnits
	% calculate bonus
    try
	bon(:,i) = spikes2exp(vector2spikes(teachCollectMat(:,i),...
		dt), Tsim, dt, tau);
    catch ME
        disp(ME.message);
    end
end

% outputWeights = zeros(nOutputUnits, nInternalUnits);
% for i=1:nInternalUnits
% 	outputWeights(:, i) = outputWeights(:, i) + bon'*stateCollectMat(:,i);
% end
outputWeights = bon'*stateCollectMat;

mw = mean(mean(outputWeights));
outputWeights = outputWeights / mw;

