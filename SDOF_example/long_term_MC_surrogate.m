clearvars
close all
clc

dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example');
addpath('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example\ML');

tag = 'MonteCarlo_surrogate';

figdir = strcat(cd,'\figures\',tag);
mkdir(figdir);

surrogate = load('surrogate_ann');

savedir = strcat(cd,'\saved\',tag);
mkdir(savedir);


%%

xrange = 0.1:0.1:2;

for i = 1:length(xrange)
    
    Mcount = 0;
    NN = 1e8;
    m = 2;
    for j = 1:m
        urandom = mvnrnd(zeros(4,1),eye(4),NN);
        Xd_MC = surrogate.net(urandom');
        Mcount = Mcount+ sum(Xd_MC <= xrange(i));
        clear Xd_MC urandom
    end
    
    Fxrange(i) = ( Mcount/(m*NN) )^(6*24*365*100);
end

save(strcat(savedir,'\','Fx_MC'),'xrange','Fxrange');



%%

Xcrit = 0.736;

Mcount = 0;
NN = 1e8;
m = 20;
for i = 1:m
    urandom = mvnrnd(zeros(4,1),eye(4),NN);
    Xd_MC = surrogate.net(urandom');
    Mcount = Mcount+ sum(Xd_MC <= Xcrit);
    clear Xd_MC urandom
end

Fx = ( Mcount/(m*NN) )^(6*24*365*100);


