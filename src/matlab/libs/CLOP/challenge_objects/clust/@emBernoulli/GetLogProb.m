function dat  =  GetLogProb(algo,dat)

% find the corresponding log prob of an instance in each mixture of each class
% so it take input an (Totalexamples x features) matrix and output 
% a matrix (Totalexamples x totalmixtures) matrix
% the i,jth element is the probability of instance i in jth mixture
% also total mixtures = mixturesP + mixturesN
dat = bin_features(algo,dat);
x = get_x(dat);
[Examples Features] = size(x);

%convert the prob to log scale .. these are prob of ones
ProbP = log10(algo.probP);
ProbN = log10(algo.probN);

%convert the prob to log scale .. these are prob of zeros
ProbZeroP = log10(1-algo.probP);
ProbZeroN = log10(1-algo.probN);

%this matrix will have log prob of each instance w.r.t a mixture
%for the ones
MixProbPos = x*ProbP';
MixProbNeg = x*ProbN';
%this matrix will have log prob of each instance w.r.t a mixture
%for the zeros
MixProbZeroPos = (~x)*ProbZeroP';
MixProbZeroNeg = (~x)*ProbZeroN';

%now make the overall mixture probabilities
MixProbPos = MixProbPos + MixProbZeroPos;
MixProbNeg = MixProbNeg + MixProbZeroNeg;

% now we can concatenate the two matrices into one matrix and pass as output
 
dat = set_x(dat,[MixProbPos MixProbNeg]);
dat = set_name(dat,[get_name(dat) ' -> ' get_name(algo)]); 
