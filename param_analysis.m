% parameter analysis
% Analyze the classification sensitivity vesus regression parameter.
% Write data to 'param_analysis_<datasetName>.mat'

clear
kps = [0.000001 0.00001 0.0001 0.001 0.01 0.1 0.5 1 4];
costs = [-10:1:10, 20:20:100];
i = 1;
regs = [0.01:0.01:0.1 0.1:0.1:1 1:20];
testAcc = zeros(1, length(regs));
datasetName = 'PreBeefScale'; % set up your own dataset name
for reg = regs
    [testAcc(i)] = NormalRV(datasetName, reg, 200, 50, costs, kps, 0, 0);
%     [testAcc(i)] = NormalRV('PreCar', reg, 100, 50, 1, 1e-3, 0, 0);
    i = i + 1;
end
plot(testAcc);
save(['param_analysis_' datasetName]);
