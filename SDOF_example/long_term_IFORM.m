clearvars
close all
clc

dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example');


TT = @(x) transform_x_to_u( x );
TTinv = @(u) transform_u_to_x( u );


tag = 'iform';

figdir = strcat(cd,'\figures\',tag);
mkdir(figdir);

%%

Ftarget = 1-1/(365*24*6*100);

Beta = norminv(Ftarget);
options = optimoptions(@fmincon,...
    'Display','none','Algorithm','sqp');

obj_fun = @(u) 1/cellfun(@(y) y(4),{TTinv(u)});

u0 = [1 1 1 1];

limit_state = @(u) limit_state_iform(u,Beta);

problem = createOptimProblem('fmincon','x0',u0,...
    'objective',obj_fun,...
    'nonlcon',limit_state,...
    'options',options);
gs = GlobalSearch;

uopt = run(gs,problem);

TTinv(uopt)








