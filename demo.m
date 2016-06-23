clear; clc;
warning off
addpath ./RV_kernel
addpath ./compute_Kernel_matrix
addpath ./libsvm
addpath ./prepared_datasets
addpath(genpath('./lsm'));

names = {'PreCoffee' };
R_nos = [200];
dataSetIndex = 1;
name = names{dataSetIndex};

R_no = R_nos(dataSetIndex);                                       %number of the reservior units, need to set
nForgetPoints = 50;                                               % forgeting points in RV, need to set
lambdas = [0 1e-6 1e-5 1e-4 1e-3 1e-2 1e-1 0.5 1:5 10 30 50 100]; %parameters for ridge regression, need to set
costs = [-5:1:5, 10:10:100];
kps = [0.000001 0.00001 0.0001 0.001 0.01 0.1 0.5 1:10 20 30 50];

disp(['Test dataset message: @' num2str(dataSetIndex)]);
disp(['Dataset: ' name]);
disp(['R_no: ' num2str(R_no)]);
disp(['lambdas: ' num2str(lambdas)]);
disp(['costs: ' num2str(costs)]);
disp(['kps: ' num2str(kps)]);
%-------------------------classification--------------------------------%
% This section conduct the classification. If there are tunable parameters,
% jump to adj_param.m.

[normal_testAcc] = NormalRV(name,lambdas,R_no,nForgetPoints,costs,kps,0,0); 
% the parameter 0 indicates a analogue series, otherwise 1

[GMM_testAcc] = GMMRV(name,lambdas,R_no,nForgetPoints,costs,kps,1,0);

[fisher_testAcc] = fisherRV(name,lambdas,R_no,nForgetPoints,costs,kps,1,0);

[Sampling_testAcc] = SamplingRV(name,lambdas,R_no,nForgetPoints,costs,kps,0);
