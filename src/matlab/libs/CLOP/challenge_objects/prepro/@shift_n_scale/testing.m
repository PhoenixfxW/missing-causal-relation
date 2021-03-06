function dat  =  testing(algo,dat)
%dat =  testing(algo,dat)
% Preprocess with scaling parameters.
% Inputs:
% algo -- A "scale" object.
% dat -- A test data object.
% Returns:
% dat -- Preprocessed data.

% Isabelle Guyon -- September 2005 -- isabelle@clopinet.com

if isempty(algo.offset) | isempty(algo.factor) return; end

X=get_x(dat); 

X=(X-algo.offset)/algo.factor;
if algo.take_log, 
    X(X<=0)=eps; % avoid taking the log of negative or 0 values
    X=log(X); 
end

dat=set_x(dat, X);

dat=set_name(dat,[get_name(dat) ' -> ' get_name(algo)]); 
  

 