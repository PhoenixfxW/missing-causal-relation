function dat  =  testing(algo,dat)
%dat =  testing(algo,dat)
% Preprocess with a 2d fft (2 dimensional square image data assumed).
% Inputs:
% algo -- A "standard" object.
% dat -- A test data object.
% Returns:
% dat -- Preprocessed data.

% Isabelle Guyon -- September 2005 -- isabelle@clopinet.com

X=get_x(dat); 
[p,n]=size(X);

dn=sqrt(n); % square image dimension
dp=dn;

% Fill with image and convolve
for k=1:p
    x=abs(fftshift(fft2(reshape(X(k,:),dn,dp))));
    X(k,:)=x(:);
end

dat=set_x(dat, X);

dat=set_name(dat,[get_name(dat) ' -> ' get_name(algo)]); 
  

 