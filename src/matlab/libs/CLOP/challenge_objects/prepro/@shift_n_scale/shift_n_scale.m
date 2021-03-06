
function a = shift_n_scale(hyper) 
%=============================================================================
% SHIFT_N_SCALE object for preprocessing by linear scaling             
%=============================================================================  
% a=shift_n_scale(hyper) 
%
% Generates a "shift_n_scale" object. 
%
% The members offset and factor can be set as a hyperparameters, 
% or subject to training.
% If trained, offset = min(min(X)) and factor = max(max(X-offset))
%
%    offset              -- offset to be subtracted from the data.              
%    factor              -- scaling factor by which the data gets divided.
%    take_log            -- 0/1 flag indicating whther one should take the log.
%
% Methods:
%  train, test 
%
%=============================================================================
% Author of code: Isabelle Guyon -- isabelle@clopinet.com -- September 2005
%=============================================================================

a.IamCLOP=1;

% <<------hyperparam initialisation------------->> 
a.display_fields={'offset', 'factor', 'take_log'};
a.offset=   default([], [-Inf Inf]);
a.factor=   default([], [eps Inf]); 
a.take_log= default(0, {0, 1}); 

% <<------model------------->>
algoType=algorithm('shift_n_scale');
a= class(a,'shift_n_scale',algoType);

a.algorithm.verbosity=1;

eval_hyper;

 

 
 





