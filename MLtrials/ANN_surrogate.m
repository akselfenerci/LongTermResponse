clearvars
% close all
dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\MLtrials');

training_data = load('Training_data_surrogate.mat');

%%

input = training_data.Data.Input;
out = training_data.Data.Output;

net = feedforwardnet(20);
net = train(net,input,out);



