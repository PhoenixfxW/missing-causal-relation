function [dout,alg] =  training(a,d)

if a.algorithm.verbosity>0
    disp(['training ' get_name(a) '.... '])
end


numEx=get_dim(d);
%mx=mean(d.X);
my=mean(d.Y);

  X=d.X;
  Y=d.Y;
  
%  center x in feature space
K=get_kernel(a.child,d);
I=eye(length(K));  
O=ones(length(K))/length(K);
K=(I-O)*K*(I-O);               % centering
a.Kc=K;

%  center output in linear output space
Y0=Y;
Y=d.Y -repmat(my,get_dim(d),1);



U=[];
T=[];
% W=[];
C=[];

k=0;
maxK=a.nroflatent;
eps=a.epsilon;
eps2=a.epsilon2;
while(norm(Y)>a.epsilon & k < maxK)
    k=k+1;
%      if a.algorithm.verbosity>0
%          fprintf('kpls Iteration : %d\n',k);
% end
%      fprintf('.\n',k);
     diff=1;
    
    u=rand(numEx,1);
    uold=u;
    t=1-2*rand(numEx,1);
    told=t;
    [t,scale,z]=svd(K*Y);
    t=t(:,1);
    c=Y'*t;
    u=Y*c;
    u=u/norm(u);
    
%     while(abs(diff)>eps2)
% %         abs(diff)
%         t=K*u;
%         t=t/norm(t);
%         c=Y'*t;
%         u=Y*c;
%         u=u/norm(u);
%         
%         diff= 1- abs(u'*uold) +1-abs(t'*told);
%         uold=u;
%         told=t;
% %         pause(0.001);
% %                diff
%     end
% %     W=[W,w];
    C=[C,c];
    U=[U,u];
    T=[T,t];
    K=K-t*t'*K-K*t*t'+t*t'*K*t*t';
    Y=Y-t*t'*Y;
    %     norm(Y)
    %     input('')
%     pause(0.001);
end

alg=a;
alg.nroflatent=k;
alg.dtraining=d;
alg.U=U;
alg.T=T;
% alg.W=W;
alg.C=C;

K=get_kernel(a.child,d);

dout=test(alg,d);

