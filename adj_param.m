function [ testAcc ] = adj_param( datasetName, R_no, lambdas, costs, kps, metric, dt_out,varargin )
%ADJ_PARAM adjust the parameters
%   This function will print the relevant parameter settings, and call
%   metric to caculate the classification accuracy.
%   If you do not want to see the message printed, use the below 
%   functions to adjust parameters dirctly, instead of use this function:
%   METRIC(datasetName,lambdas,R_no,nForgetPoints,costs,kps,0, dt_out);
%       METRIC is one of NormalRV, GMMRV, fiserRV and SamplingRV.
%
%   EXAMPLE:
%       [ testAcc ] = ADJ_PARAM( datasetName, R_no, lambdas, costs,...
%           kps, metric, dt_out, 'nForgetPoints', 50 );
%
%   Input:
%       datasetName - name of dataset to be classification, see the mat
%       files in 'prepared_datasets' folder as example.
%       R_no        - the number of neurons in reservoir. You'd better
%       use the lsm_weight_* to find the best choice of R_no and lambdas.
%       lambdas     - the list of regression coefficient.
%       costs, kps  - list of svm parameters, to learn more about this, 
%       please read relevant materials about 'libsvm'
%       metric      - kernel metric, one of NormalRV, GMMRV, fiserRV and 
%       SamplingRV
%       dt_out      - lsm input and output signal time step, if dt_out<=0, 
%       default value(4e-3) will be used instead.
%       'nForgetPoints', nForgetPoints - points to forget as the init 
%       points
%   Output:
%       testAcc     - the classfication accuracy of the dataset with the 
%       specific metric. The accuracy will be the best one of different 
%       parameters(lambdas, costs, kps), see NormalRV, GMMRV, fiserRV, 
%       SamplingRV for more details
%   
%   See also NormalRV, GMMRV, fiserRV, SamplingRV, lsm_weight_normal,
%   lsm_weight_GMM, lsm_weight_fisher, lsm_weight_sampling.
%   
%   Author: Junyuan Hong, 2015-5, jyhong836@gmail.com

if nargin<6
    if nargin<5
        if nargin<4
            costs = [-5:1:5, 10:10:100];
        end
        kps = [0.000001 0.00001 0.0001 0.001 0.01 0.1 0.5 1:10 20 30 50];
    end
    metric = 'NormalRV';
end

% R_no = ;%200;%number of the reservior units, need to set
nForgetPoints = 50; % forgeting points in RV, need to set
% lambdas = 1e-6;%[0 1e-6 1e-5 1e-4 1e-3 1e-2 1e-1 0.5 1:5 10 30 50 100];%parameters for ridge regression, need to set

args = varargin;
nargs = length(args);
for i=1:2:nargs
    switch args{i}
        case 'nForgetPoints', nForgetPoints = args{i+1};
        otherwise, disp('un');
    end
end

disp('---------------------------------------');
% disp(['Test dataset message: @' num2str(dataSetIndex)]);
disp(['Metric: ' metric]);
disp(['Dataset: ' datasetName]);
disp(['R_no: ' num2str(R_no)]);
disp(['lambdas: ' num2str(lambdas)]);
disp(['costs: ' num2str(costs)]);
disp(['kps: ' num2str(kps)]);

tdata = load(datasetName);
disp(['series length: ' num2str(length(tdata.training{1}))]);
disp(['classes number: ' num2str(max(max(tdata.training_label)))]);
clear tdata

% choose a metric to run
switch metric
    case 'NormalRV',   [testAcc] = NormalRV(datasetName,lambdas,R_no,nForgetPoints,costs,kps,0, dt_out);
    case 'GMMRV',      [testAcc] = GMMRV(datasetName,lambdas,R_no,nForgetPoints,costs,kps,1, dt_out);
    case 'fisherRV',   [testAcc] = fisherRV(datasetName,lambdas,R_no,nForgetPoints,costs,kps,1, dt_out);
    case 'SamplingRV', [testAcc] = SamplingRV(datasetName,lambdas,R_no,nForgetPoints,costs,kps, dt_out);
    otherwise, warning(['Unknown metric: ' metric]);
end

end

