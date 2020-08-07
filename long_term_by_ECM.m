

clearvars
% close all
dbstop if error



dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse');

RSM = load('RSmodel');


TT = @(x) transform_env_x_to_u( x );

TTinv = @(u) transform_env_u_to_x( u );

% test the transform
% dummy = randn(3,3) + 5;
% invdummy = TT(dummy)
% TTinv(invdummy)

%%

Ftarget = 1-1/(4*365*24*6);

Beta = norminv(Ftarget);


options = optimoptions(@fmincon,...
    'Display','iter','Algorithm','interior-point','TolX',1e-8,'TolFun',1e-8,'FunValCheck','on','MaxFunEvals',1000,'MaxIter',1000,'PlotFcns','optimplotfval');

obj_fun = @(x) -predict(RSM.lmSTD,x);

limit_state = @(x) limit_state_ECM(TT(x),Beta);

% start at max vel
x0 = TTinv([Beta 0 0]);


[xopt,fval] = fmincon(obj_fun,x0,...
    [],[],[],[],[],[],limit_state,options);

resp = -obj_fun(xopt);


