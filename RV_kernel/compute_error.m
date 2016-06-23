function err = compute_error(estimatedOutput, correctOutput)

 
nEstimatePoints = size(estimatedOutput,1) ; 
nForgetPoints = size(correctOutput,1) - nEstimatePoints ; 
correctOutput = correctOutput(nForgetPoints+1:end,:) ; 

correctVariance = var(correctOutput) ; 
meanerror = (sum((estimatedOutput - correctOutput).^2))/nEstimatePoints ;

err =(((meanerror./correctVariance))) ; 



