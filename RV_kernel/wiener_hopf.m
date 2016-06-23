function outputWeights = wiener_hopf(stateCollectMat, teachCollectMat,val)
% computes ESN output weights from collected network states and collected 
% teacher outputs. Mathematically this is a linear regression. 
% Uses the Wiener-Hopf solution, which runs faster (but is less numerically
% stable) than if the weights are computed via the pseudoinverse.

% Created April 30, 2006, D. Popovici
% Copyright: Fraunhofer IAIS 2006 / Patent pending


% runlength = size(stateCollectMat,1);
% covMat = stateCollectMat' * stateCollectMat / runlength;
% pVec = stateCollectMat' * teachCollectMat / runlength;
% outputWeights = (inv(covMat) * pVec)';

% val = 1e-3;

if val ==0
    outputWeights = (pinv(stateCollectMat)*teachCollectMat)' ; 
else
    runlength = size(stateCollectMat,1);
    %covMat = stateCollectMat' * stateCollectMat / runlength;
    A=stateCollectMat' * stateCollectMat;
    m=size(A);
    covMat = (A + (val *eye(m)) )/ runlength;
    pVec = stateCollectMat' * teachCollectMat / runlength;
    %outputWeights = (inv(covMat) * pVec)';
    outputWeights = (covMat \ pVec)';
end



