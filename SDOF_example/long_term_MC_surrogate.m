clearvars
close all
clc
0
dbstop if error

cd('C:\Users\akselfe\Documents\GitHub\LongTermResponse\SDOF_example');
addpath('C:\Users\akselfe\Documents\GitHub\LongTermResponse\SDOF_example\ML');

tag = 'MonteCarlo_surrogate';

figdir = strcat(cd,'\figures\',tag);
mkdir(figdir);


savedir = strcat(cd,'\saved\',tag);
mkdir(savedir);



surrogate = load(strcat(cd,'\saved\surrogate\surrogate_ann'));


%%

xrange = 0.001:0.01:2.5;

for i = 1:length(xrange)
    
    Mcount = 0;
    NN = 1e8;
    m = 20;
    for j = 1:m
        urandom = mvnrnd(zeros(4,1),eye(4),NN);
        Xd_MC = surrogate.net(urandom');
        Mcount = Mcount+ sum(Xd_MC <= xrange(i));
        clear Xd_MC urandom
    end
    
%     Fxrange(i) = ( Mcount/(m*NN) )^(6*24*365*100);
    Fxrange(i) =( Mcount/(m*NN) )^(6*24*365);
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


%% plotting

CDFlong = load(strcat(savedir,'\Fx_MC.mat'));

figure; 
plot(CDFlong.xrange,CDFlong.Fxrange);