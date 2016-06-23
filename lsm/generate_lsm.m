function lsm = generate_lsm( nInputUnits, nInternalUnits, nOutputUnits, varargin )
% Creates an ESN set up for use in multiple-channel output association tasks. 
% The number of input, internal, and output 
% units have to be set. Any other option is set using the format 
% 'name_of_options1',value1,'name_of_option2',value2, etc.
% 
%%%%% input arguments:
% nInputUnits: the dimension of the input 
% nInternalUnits: size of the Esn
% nOutputUnits: the dimension of the output
%
%%%%% optional arguments:
% 'inputScaling': a nInputUnits x 1 vector
%
% 'inputShift': a nInputUnits x 1 vector. 
%
% 'teacherScaling': a nOutputUnits x 1 vector
%
% 'teacherShift': a nOutputUnits x 1 vector. 
%
% 'noiseLevel': a small number containing the amount of uniform noise to be
%  added when computing the internal states
%
% 'learningMode': a string ('offline_singleTimeSeries', 'offline_multipleTimeSeries' or 'online')
%     1. Case 'offline_singleTimeSeries': trainInput and trainOutput each represent a 
%        single time series in an array of size sequenceLength x sequenceDimension
%     2. Case 'offline_multipleTimeSeries': trainInput and trainOutput each represent a 
%        collection of K time series, given in cell arrays of size K x 1, where each cell is an
%        array of size individualSequenceLength x sequenceDimension
%     3. Case 'online': trainInput and trainOutput are a single time
%        series, output weights are adapted online
%
% 'reservoirActivationFunction': a string ("tanh", "identity", "sigmoid01") ,
%
% 'outputActivationFunction': a string("tanh", "identity", "sigmoid01") ,
%
% 'inverseOutputActivationFunction': the inverse to
%    outputActivationFunction, one of 'atanh', 'identity', 'sigmoid01_inv'.
%    When choosing the activation function, make sure the inverse
%    activation function is corectly set.
%
% 'methodWeightCompute': a string ('pseudoinverse', 'wiener_hopf'). It  
%    specifies which method to use to compute the output weights given the
%    state collection matrix and the teacher
%
% 'spectralRadius': a positive number less than 1. 
%
% 'feedbackScaling': a nOutputUnits x 1 vector, indicating the scaling
%     factor to be applied on the output before it is fed back into the network
%
% 'type': a string ('plain_lsm', 'leaky_lsm' or 'twi_lsm')
% 'trained': a flag indicating whether the network has been trained already
% 'timeConstants': option used in networks with type == "leaky_lsm", "leaky1_lsm" and "twi_lsm".
%                      Is given as column vector of size lsm.nInternalUnitsm, where each entry 
%                      signifies a time constant for a reservoir neuron.
% 'leakage': option used in networks with type == "leaky_lsm" or "twi_lsm"
% 'RLS_lambda': option used in online training(learningMode == "online") 
% 'RLS_delta': option used in online training(learningMode == "online")
%
% for more information on the Echo State network approach take a look at
% the following tutorial : 
% http://www.faculty.iu-bremen.de/hjaeger/pubs/ESNTutorialRev.pdf

% Version 1.0, April 30, 2006
% Copyright: Fraunhofer IAIS 2006 / Patent pending
% Revision 1, June 6, 2006, H. Jaeger
% Revision 2, Feb 23, 2007, H. Jaeger
% Revision 3, June 27, 2007, H. Jaeger 
% Revision 4, July 1, 2007, H. Jaeger: 
%    - changed lsm.timeConstant to lsm.timeConstants
%    - deleted lsm.retainment
%    - deleted lsm.internalWeights (to enforce that this is set outside
%    this generation script)
% Revision 5, July 29, 2007, H. Jaeger: bugfix (for cases of zero input or
%    output length)
% Revision 6, Jan 28, 2009, H. Jaeger: bugfix (deleted defunct error
%                             catching routine for leaky / twilsm
%                             reservoirs)


%%%% set the number of units
lsm.nInternalUnits = nInternalUnits; 
lsm.nInputUnits = nInputUnits; 
lsm.nOutputUnits = nOutputUnits; 
  
connectivity = min([10/nInternalUnits 1]);
nTotalUnits = nInternalUnits + nInputUnits + nOutputUnits; 

lsm.internalWeights_UnitSR = full(generate_internal_weights(nInternalUnits, ...
                                                connectivity));
lsm.nTotalUnits = nTotalUnits; 

% input weight matrix has weight vectors per input unit in colums
lsm.inputWeights = 2.0 * rand(nInternalUnits, nInputUnits)- 1.0;

% output weight matrix has weights for output units in rows
% includes weights for input-to-output connections
lsm.outputWeights = zeros(nOutputUnits, nInternalUnits + nInputUnits);

%output feedback weight matrix has weights in columns
lsm.feedbackWeights = (2.0 * rand(nInternalUnits, nOutputUnits)- 1.0);

%init default parameters
if nInputUnits > 0
    lsm.inputScaling  = ones(nInputUnits, 1);  lsm.inputShift    = zeros(nInputUnits, 1);
else
    lsm.inputScaling = []; lsm.inputShift = [];
end
if nOutputUnits > 0
    lsm.teacherScaling = ones(nOutputUnits, 1); lsm.teacherShift  = zeros(nOutputUnits, 1);
else
    lsm.teacherScaling = []; lsm.teacherShift  =  [];
end
lsm.noiseLevel = 0.0 ; 
lsm.reservoirActivationFunction = 'tanh';
lsm.outputActivationFunction = 'identity' ; % options: identity or tanh or sigmoid01
lsm.methodWeightCompute = 'pseudoinverse' ; % options: pseudoinverse and wiener_hopf
lsm.inverseOutputActivationFunction = 'identity' ; % options:
                                                   % identity or
                                                   % atanh or sigmoid01_inv
lsm.spectralRadius = 1 ; 
lsm.feedbackScaling = zeros(nOutputUnits, 1); 
lsm.trained = 0 ; 
lsm.type = 'plain_lsm' ; 
lsm.timeConstants = ones(lsm.nInternalUnits,1); 
lsm.leakage = 0.5;  
lsm.learningMode = 'offline_singleTimeSeries' ; 
lsm.RLS_lambda = 1 ; 

% CSIM specific parameters
lsm.dt_out = 4e-3;
lsm.dt_sim = 1e-4;
lsm.seed = 42;
lsm.SpikingInput = 0;

args = varargin; 
nargs= length(args);
for i=1:2:nargs
  switch args{i},
   case 'inputScaling', lsm.inputScaling = args{i+1} ; 
   case 'inputShift', lsm.inputShift= args{i+1} ; 
   case 'teacherScaling', lsm.teacherScaling = args{i+1} ; 
   case 'teacherShift', lsm.teacherShift = args{i+1} ;     
   case 'noiseLevel', lsm.noiseLevel = args{i+1} ; 
   case 'learningMode', lsm.learningMode = args{i+1} ; 
   case 'reservoirActivationFunction',lsm.reservoirActivationFunction=args{i+1};
   case 'outputActivationFunction',lsm.outputActivationFunction=  ...
                        args{i+1};        
   case 'inverseOutputActivationFunction', lsm.inverseOutputActivationFunction=args{i+1}; 
   case 'methodWeightCompute', lsm.methodWeightCompute = args{i+1} ; 
   case 'spectralRadius', lsm.spectralRadius = args{i+1} ;  
   case 'feedbackScaling',  lsm.feedbackScaling = args{i+1} ; 
   case 'type' , lsm.type = args{i+1} ; 
   case 'timeConstants' , lsm.timeConstants = args{i+1} ; 
   case 'leakage' , lsm.leakage = args{i+1} ; 
   case 'RLS_lambda' , lsm.RLS_lambda = args{i+1};
   case 'RLS_delta' , lsm.RLS_delta = args{i+1};
   case 'dt_out', lsm.dt_out = args{i+1};
   case 'dt_sim', lsm.dt_sim = args{i+1};
   case 'seed',   lsm.seed   = args{i+1};
   case 'SpikingInput', lsm.SpikingInput = args{i+1};
       
   otherwise error('the option does not exist'); 
  end      
end

%%%% error checking
% check that inputScaling has correct format
if size(lsm.inputScaling,1) ~= lsm.nInputUnits
    error('the size of the inputScaling does not match the number of input units'); 
end
if size(lsm.inputShift,1) ~= lsm.nInputUnits
    error('the size of the inputScaling does not match the number of input units'); 
end
if size(lsm.teacherScaling,1) ~= lsm.nOutputUnits
    error('the size of the teacherScaling does not match the number of output units'); 
end
if size(lsm.teacherShift,1) ~= lsm.nOutputUnits
    error('the size of the teacherShift does not match the number of output units'); 
end
if length(lsm.timeConstants) ~= lsm.nInternalUnits
    error('timeConstants must be given as column vector of length lsm.nInternalUnits'); 
end
if ~strcmp(lsm.learningMode,'offline_singleTimeSeries') &&...
        ~strcmp(lsm.learningMode,'offline_multipleTimeSeries') && ...
        ~strcmp(lsm.learningMode,'online')
    error('learningMode should be either "offline_singleTimeSeries", "offline_multipleTimeSeries" or "online" ') ; 
end
if ~((strcmp(lsm.outputActivationFunction,'identity') && ...
        strcmp(lsm.inverseOutputActivationFunction,'identity')) || ...
        (strcmp(lsm.outputActivationFunction,'tanh') && ...
        strcmp(lsm.inverseOutputActivationFunction,'atanh')) || ...
        (strcmp(lsm.outputActivationFunction,'sigmoid01') && ...
        strcmp(lsm.inverseOutputActivationFunction,'sigmoid01_inv')))  ...
error('outputActivationFunction and inverseOutputActivationFunction do not match'); 
end

% init csim
csim('set', 'verboseLevel', 0);
csim('destroy');
csim('set','dt',lsm.dt_sim);
csim('set','randSeed',lsm.seed);
lsm.simStateIndex = 0;


end

