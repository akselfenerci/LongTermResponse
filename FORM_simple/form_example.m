clear all
close all
clc

dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\FORM_simple');
addpath('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse');



RSM = load('RSmodel');

TT = @(x) transform_variables_x_to_u( x,RSM );

TTinv = @(u) transform_variables_u_to_x( u,RSM );

xx = [20 2 1 0.5];

u = TT(xx);

xback = TTinv(u);



%%




options = optimoptions(@fmincon,...
    'Display','iter','Algorithm','interior-point');

obj_fun = @(x) norm(TT(x)); 

[xopt,fval] = fmincon(obj_fun,[10 2 1 0.1],...
    [],[],[],[],[],[],@limit_state,options);

Flong = normcdf(norm(TT(xopt)));

Tratio = (365*24*6);
F_char = Flong^Tratio;

Ftarget = 1-1/(365*24*6);
F_char_target = Ftarget^Tratio;

err = 100*abs(F_char - F_char_target)/F_char_target;
