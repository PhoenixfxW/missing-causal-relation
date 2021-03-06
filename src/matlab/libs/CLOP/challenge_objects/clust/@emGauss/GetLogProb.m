function dat  =  GetLogProb(algo,dat)

% find the corresponding log prob of an instance in each mixture of each class
% so it take input an (Totalexamples x features) matrix and output 
% a matrix (Totalexamples x totalmixtures) matrix
% the i,jth element is the probability of instance i in jth mixture
% also total mixtures = mixturesP + mixturesN
%make data only out of continuous features first
if ~strcmp(algo.FeatureType,'cont')
    dat = cont_features(algo,dat);
end
x = get_x(dat);

%first get prob in mixtures of +ve class
ProbP = GetLogProbMatrix(x,algo.meanP,algo.covP);
%now get prob in mixtures of -ve class
ProbN = GetLogProbMatrix(x,algo.meanN,algo.covN);

dat=set_x(dat,[ProbP ProbN]); 
dat=set_name(dat,[get_name(dat) ' -> ' get_name(algo)]); 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%given a matrix x and mixture mean vectors and diagonal cov matrices find the
%Gaussian prob of each instance in each matrix
% x = total_instance x features matrix
% mean = mixtures x features matrix
% cov = mixtures x features matrix
% ProbMatrix = instances x mixtures matrix...i,jth entry = prob of instance
% i in jth mixture
function ProbMatrix = GetLogProbMatrix(x,mean,cov)
[mixtures features] = size(mean);
ProbMatrix = [];
for i=1:1:mixtures
    tempMatrix = GetLogGaussianProb(x,mean(i,:),cov(i,:));
    ProbMatrix = [ProbMatrix tempMatrix];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%given a matrix x and mean vector mean and diagonal cov matrix find the
%log of Gaussian prob of each instance 
% x = total_instance x features matrix
% mean = 1 x features matrix
% cov = 1 x features matrix
%ProbVector = total_instance x 1 matrix
%formula:        -(features/2)*ln(2*PI)
%                -1/2 * ln (determinant of cov matrix)
%               -1/2 * exponent part
%       the exponent part -0.5*vector(x-mean)*inv(cov)*(x-mean)
%       so if entries of x-mean are diff and entries of inv cov are ic then
%       ith exponent part = sum(-0.5*diff(i)*diff(i)*ic(i))
function ProbVector = GetLogGaussianProb(x,mean,cov)
[row col] = size(x);    
%get inverse of covariance matrix and make it a vector
invCov = diag(cov);
invCov = inv(invCov);
invCov = diag(invCov);          %making it a vector
%also get the determinant of cov matrix
deter = det(diag(cov));
%---------------------getting exponent part
%get x-mean
for i=1:1:col
    x(:,i) = x(:,i) - mean(i);
end
%square it
x = x.*x;
%now multiply by inverse cov
x = x*invCov;
%now lets complete the exponent part
x = -0.5*x;
% now add the rest 
ProbVector = -0.5*col*log(2*pi);
ProbVector = ProbVector - 0.5*log(deter);
ProbVector = ProbVector + x;


