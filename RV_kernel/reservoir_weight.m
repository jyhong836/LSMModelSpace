function [data,error] = reservoir_weight(X, R_no)
% X1 (X2) is a time series data [N,d] = size(X)
% d is the dimension of the series
% N is the total number of points in X
% R_no is number of resevior nodes
% default number of R_no = 25;
% dist2 is the distance between X1 and X2
% 
if (nargin<2)
    R_no = 25;
end
rand('state',2);
randn('state',2);

X = X';

[N,dim] = size(X);

nInputUnits = dim+1;
nInternalUnits = R_no;
nOutputUnits = dim;

m = rand(nInternalUnits,nInputUnits);
y = zeros(nInternalUnits,nInputUnits);

y(m>0.5)=1;
y(m<0.5)=-1;

% selested parameter values based on training
v = 0.02;
r = 0.6;
r1 = 0.9;
jump_size = 18;
d = 10^(-0.1*141); % ridge regression parameter


inputScalingVect = ones(nInputUnits,1)*0.5;
inputShiftVect = zeros(nInputUnits,1)-0.5;
teacherScalingVect = ones(nOutputUnits,1)*2;
teacherShiftVect =zeros(nOutputUnits,1)-0.5;
feedbackScalingVect = ones(nOutputUnits,1)*0;

%esn = generate_ffesn(nInputUnits, nInternalUnits, nOutputUnits,1,r,0,r,r1,0,0,0,jump_size,10,10,10, ...
%    'spectralRadius',0.9,'inputScaling',inputScalingVect,'inputShift',inputShiftVect, ...
 %   'teacherScaling',teacherScalingVect,'teacherShift',teacherShiftVect,'feedbackScaling',feedbackScalingVect, 'type', 'plain_esn');
esn = generate_esn(nInputUnits, nInternalUnits, nOutputUnits,...
    'spectralRadius',0.9,'inputScaling',inputScalingVect,'inputShift',inputShiftVect, ...
    'teacherScaling',teacherScalingVect,'teacherShift',teacherShiftVect,'feedbackScaling',feedbackScalingVect, ...
    'type', 'plain_esn'); 
esn.internalWeights = esn.internalWeights_UnitSR;
esn.inputWeights = y*v;

%%%% train the ESN
nForgetPoints = 100 ; % discard the first 100 points
esn.noiseLevel = 0;

%% 
step = 1;
trainInputSequence1 = [X(1:N-step,:) ones(N-step,1)];
trainOutputSequence1 = X(1+step:N,:);
%% 
trainedEsn1 = train_esn(trainInputSequence1, trainOutputSequence1, esn, nForgetPoints,d) ;
[predictedTrainOutput1] = test_esn(trainInputSequence1, trainedEsn1,nForgetPoints) ;
trainError=compute_error(predictedTrainOutput1, trainOutputSequence1);

data1 = trainedEsn1.outputWeights;
data = data1(:,1:R_no);
error = mean(trainError);



