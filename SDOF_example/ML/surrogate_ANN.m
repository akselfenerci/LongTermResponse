clearvars
close all


dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example\ML');

dataset = load('Dataset_unifromgrid.mat');

%%
input = dataset.Input';
out = dataset.Output';

net = feedforwardnet(20);

net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;


% default algorith is Levenberg-M. 
net.trainFcn = 'trainbr'; % Bayesian regularization
% net.trainFcn = 'trainscg'; % Scaled Conjugate Gradient


net = train(net,input,out);

save('surrogate_ann','net');
