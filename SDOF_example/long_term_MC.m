clearvars
close all
clc

dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example');


tag = 'MonteCarlo';

figdir = strcat(cd,'\figures\',tag);
mkdir(figdir);

TTinv = @(u) transform_u_to_x(u);

%%

urandom = mvnrnd(zeros(4,1),eye(4),1e8);


xrandom = TTinv(urandom);
Xd_MC = xrandom(:,4);

Xcrit = 0.736;

Fx = ( sum(Xd_MC <= Xcrit)/length(Xd_MC) )^(6*24*365*100);


