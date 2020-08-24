clearvars
close all


dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example\ML');

main = 'C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example';


tag = 'surrogate';

figdir = strcat(main,'\figures\',tag);
mkdir(figdir);

savedir = strcat(main,'\saved\',tag);
mkdir(savedir);

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


[net,tr] = train(net,input,out);

save(strcat(savedir,'\surrogate_ann'),'net','tr');


plotperform(tr);
fig = gcf;
fig.Position = [680 678 560 221];
grid on;
savefig(strcat(figdir,'\','training_performance.fig'));
saveas(gcf,strcat(figdir,'\','training_performance.emf'));
close(gcf);


Outputs = net(input);
trOut = Outputs(tr.trainInd);
vOut = Outputs(tr.valInd);
tsOut = Outputs(tr.testInd);
trTarg = out(tr.trainInd);
vTarg = out(tr.valInd);
tsTarg = out(tr.testInd);
plotregression(trTarg, trOut, 'Train', vTarg, vOut, 'Validation', tsTarg, tsOut, 'Testing')
savefig(strcat(figdir,'\','training_regression.fig'));
saveas(gcf,strcat(figdir,'\','training_regression.emf'));
close(gcf);
