function a = emBernoulli(hyper) 
%=============================================================================
% Expectation maximization object for learning bernoulli mixtures             
% for binary data only
% written by Mehreen Saeed 01 June, 2007. FAST National University of Computer
%   and Emerging Sciences, Pakistan   mehreen.saeed@nu.edu.pk ;
%   mehreen.mehreen@gmail.com
%=============================================================================  
% a=em(hyperParam) 
%
% Generates an em object for bernoulli mixture models with given hyperparameters.
%
%
%   Hyperparameters (with defaults)
%   IterationsP = 20     -- Iterations for the em step for +ve examples
%   mixturesP=5          -- total number of mixtures to use for +ve
%                           examples
%   IterationsN = 20     -- Iterations for the em step for -ve examples
%   mixturesN=5          -- total number of mixtures to use for -ve
%                           examples
%   testGivesProb=0      -- flag to indicate whether test routine gives log prob
%   EliminatePriors=0    -- Indicates whether to eliminate the mixtures
%                           with priors less than a certain value...specify
%                           the threshold value here
%   Model
%    priorP              -- the prior probabilities of each mixture in +ve
%                           examples (mixturesP x 1) matrix
%    probabP            -- the probability vector for each mixture in +ve
%                           examples (mixturesP x TotalFeatures) matrix
%    priorN              -- the prior probabilities of each mixture in -ve
%                           examples (mixturesN x 1)
%    probabN            -- the probability vector for each mixture in -ve
%                           examples (mixturesN x TotalFeatures) matrix
%    PosPriorP          -- the prior of class representing +ve examples
%    NegPriorP          -- the prior of clas representing -ve examples
%
% Methods:
%  train,               -- will get mixture models
%  test                 -- if transformation to prob space is required then
%                           specify 'testGivesProb=1' and test function will 
%                           output the transformed space.  If testing is 
%                           required using mixture models then set
%                           this flag to false.
%
%    GetLogProb         -- get the log of prob matrix of instances with
%    prob of mixtures
%
% Example:
%see example for emGauss but binary features are required in this case
% 
%
%=============================================================================
% Reference : Pattern Recognition and Machine Learning by C.M.Bishop, 2006.
%
%=============================================================================

  %<<------hyperparam initialisation------------->> 
  a.IterationsP=20;
  a.mixturesP=5;    
  a.IterationsN=20;
  a.mixturesN=5;
  a.testGivesProb = 0; 
  a.EliminatePriors = 0;
  % <<-------------model----------------->> 
  a.PosPrior= 0.5;
  a.NegPrior = 0.5;
 
  a.priorP=[];
  a.probP=[];
  
  a.priorN=[];
  a.probN=[];
  
  
  algoType=algorithm('emBernoulli');
  a= class(a,'emBernoulli',algoType);
  
 if nargin==1,
    eval_hyper;
 end;





