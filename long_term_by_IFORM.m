clear all
close all
clc

dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse');
addpath('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\FORM_simple');

RSM = load('RSmodel');


TT = @(x) transform_variables_x_to_u( x,RSM );

TTinv = @(u) transform_variables_u_to_x( u,RSM );


%%

Ftarget = 1-1/(365*24*6*100);

Beta = norminv(Ftarget);

options = optimoptions(@fmincon,...
    'Display','iter','Algorithm','interior-point');

obj_fun = @(u) 1/cellfun(@(y) y(4),{TTinv(u)});

limit_state = @(u) limit_state_iform(u,Beta);


[uopt,fval] = fmincon(obj_fun,[1 1 1 1],...
    [],[],[],[],[],[],limit_state,options);

resp = 1/obj_fun(uopt);












