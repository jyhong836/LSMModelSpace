function [testAcc,valAcc] = SamplingRV(datasetsname,lambdas,R_no,nForgetPoints,costs,kps, dt_out, minBootLength)

% test  reservior kernel that using sampling methord using svm
% tune the parameter using 5 cross validation or leaveout

eval(['load(''./prepared_datasets/',datasetsname,'.mat'');']);
if exist('info', 'var')
    SpikingInput = info.spiking;
    if dt_out==0
        dt_out = info.dt;
    end
else
    SpikingInput = 0;
end

if nargin <1
    help SamplingRV;
elseif nargin ==1
    lambdas = 1;
elseif nargin ==2
    R_no = 25;
elseif nargin ==3
    n = size(training{1},2);
    nForgetPoints = min(100,n/3);
elseif nargin==4 
    costs = 100;
elseif nargin ==5
    kps = 1;
% elseif nargin ==6
%     leaveout = true;
end
if nargin <= 7
    minBootLength = 20;
end
leaveout = true;

y = training{1};
dim = size(y,1);
len = zeros(1,dim);
for i=1:dim
    Bstar = opt_block_length_REV_dec07(y(i,:)');
    len(i) = ceil(Bstar(2));
end

len = max(len);
if len< minBootLength
    L = minBootLength;
else
    L = len(1);
end


nLambdas = length(lambdas);
nKps= length(kps);
nCosts = length(costs);

nsv = zeros(nLambdas,nKps,nCosts);
acc = zeros(nLambdas,nKps,nCosts);

% using 5-cross validation to tune the parameter
kFold = 5;
classes = unique(training_label);
nClasses = length(classes);
permcell = cell(nClasses,1);
nSample = cell(nClasses,1);
minS = 1000;
for i=1:nClasses
    nSample{i} = find(training_label==classes(i));
    len = length(nSample{i});
    if minS>len
        minS = len;
    end
    permcell{i} = randperm(len);
end

if minS<5
    %using leave out
    leaveout = true;
end

if leaveout
   kFold = 1; 
end
fold_ind = ones(nClasses,1);
for k=1:kFold 
    if ~leaveout
        train_ind = [];
        test_ind = [];
        for i=1:nClasses
            fold_size = floor(length(nSample{i}) ./kFold);
            indexTr = permcell{i}([1:fold_ind(i) - 1 fold_ind(i) + fold_size:end]);
            train_ind = [train_ind ; nSample{i}(indexTr)];
            indexTe =  permcell{i}(fold_ind(i):fold_ind(i) + fold_size - 1);
            test_ind  = [test_ind;nSample{i}(indexTe)];
            fold_ind(i) = fold_ind(i)+fold_size;
        end
        trXD = training(train_ind,:); 
        tr_label = training_label(train_ind);
        teXD = training(test_ind,:);
        te_label = training_label(test_ind);
       
    else
        trXD = training;
        tr_label = training_label;
        teXD = testing;
        te_label = testing_label;
    end
    
    for i = 1:nLambdas

        val = lambdas(i);
        [trX,teX] =compute_KernelRV_sampling(trXD,teXD,R_no,L,val,nForgetPoints, dt_out, SpikingInput); 
        num1 = size(trX,1);

        X = [trX;teX];
        temp = mapstd(X');
        temp = temp';

        trX = temp(1:num1,:);
        teX = temp(num1+1:end,:);


        fold_ind = ones(nClasses,1);    

         for j=1:nKps
            kp = kps(j);
             for p=1:nCosts
                C = 10^costs(p);

                 opinion = ['-s 0 -c ' num2str(C) ' -gamma ' num2str(kp) ' -t 2 -q'];
                 model = svmtrain(tr_label, trX, opinion);
                 nSV = model.totalSV;
                 [Y0, accuracy, ~] = svmpredict(te_label,teX, model, '-b 0');
                 acc(i,j,p) = acc(i,j,p)+accuracy(1);
                 nsv(i,j,p) =nsv(i,j,p)+nSV;
             end
         end
    end
 
end
acc = acc / kFold;
nsv = nsv / kFold;


bestNsv = 0;
[bestAcc,] = max(acc(:));
acci = find(acc(:) == bestAcc);
if(length(acci)>1)
    tmpNSV = nsv(:);
    [bestNsv,] = min(tmpNSV(acci));
end

indexI = 0;
indexJ = 0;
indexP = 0;
for i = 1:nLambdas
    for j=1:nKps
        for p=1:nCosts
            if(bestNsv==0)
                if(bestAcc==acc(i,j,p))
                    indexI = i;
                    indexJ = j;
                    indexP = p;
                end
            else
                if(bestAcc==acc(i,j,p) && bestNsv==nsv(i,j,p))
                    indexI = i;
                    indexJ = j;
                    indexP = p;
                end
            end
        end
    end

end

lambda = lambdas(indexI);
kp = kps(indexJ);
C = 10^costs(indexP);

valAcc = bestAcc;

[trainX,testX] = compute_KernelRV_sampling(training,testing,R_no,L,lambda,nForgetPoints, dt_out, SpikingInput);
num1 = size(trainX,1);

X = [trainX;testX];
temp = mapstd(X');
temp = temp';

trainX = temp(1:num1,:);
testX = temp(num1+1:end,:);
%% 
opinion = ['-s 0 -c ' num2str(C) ' -gamma ' num2str(kp) ' -t 2 -q'];
model = svmtrain(training_label, trainX, opinion);
[Y0, accuracy, ~] = svmpredict(testing_label,testX, model, '-b 0');

testAcc = accuracy(1);

end



