
clearvars
% close all
dbstop if error



dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse');

RSM = load('RSmodel');

TT = @(x) transform_env_x_to_u( x );
TTinv = @(u) transform_env_u_to_x( u );

%%  training data

% uvals = mvnrnd(zeros(1,4),eye(4),50000);


u1 = 0:0.1:5;
u2 = 1:0.2:5;
u3 = 1:0.2:5;
u4 = -2:0.1:5;

[U1,U2,U3,U4] = ndgrid(u1,u2,u3,u4);

U1vec = reshape(U1,[length(U1(:)),1]);
U2vec = reshape(U2,[length(U2(:)),1]);
U3vec = reshape(U3,[length(U3(:)),1]);
U4vec = reshape(U4,[length(U4(:)),1]);

xvals = TTinv([U1vec U2vec U3vec]);

Tshort = 600;
[std] = predict(RSM.lmSTD,[xvals(:,2) xvals(:,1) xvals(:,3)]);
[stddot] = predict(RSM.lmSTDdot,[xvals(:,2) xvals(:,1) xvals(:,3)]);
std(std<0) = 1e-5;
stddot(stddot<0) = 1e-5;

[ Xd ] = short_term_extreme_inv( std,stddot,Tshort,normcdf(U4vec) );


figure; plot(xvals(:,1),std,'x')
figure; plot(xvals(:,1),real(Xd),'x')


utrain = [U1vec U2vec U3vec U4vec]';

%%   first try a response surface

% lm = fitlm(uvals,Xd ,'quadratic');
% 
% lm.Rsquared
% lm.RMSE


%% ANN

net = feedforwardnet(20);
net = train(net,utrain,real(Xd)');

perform(net,real(Xd)',net(utrain))

utest = rand(1000,4)*10-5; 

xtest = TTinv(utest(:,1:3));
[std] = predict(RSM.lmSTD,[xtest(:,2) xtest(:,1) xtest(:,3)]);
[stddot] = predict(RSM.lmSTDdot,[xtest(:,2) xtest(:,1) xtest(:,3)]);
std(std<0) = 1e-5;
stddot(stddot<0) = 1e-5;
[ xtest(:,4) ] = short_term_extreme_inv( std,stddot,Tshort,normcdf(utest(:,4)) );


Xd_test_ANN = net(utest');

perform(net,real(xtest(:,4)),Xd_test_ANN)

figure; 
plot(xtest(:,1),Xd_test_ANN,'x');
hold on;
plot(xtest(:,1),xtest(:,4),'o');



%% Montre Carlo

% Xcrit = 1.039;
% N = 0;
% num = 0;
% for i = 1:10000
%     urandom = mvnrnd(zeros(4,1),eye(4),1e6);
%     Xd_MC = net(urandom');
%     
%     num = num + sum(Xd_MC <= Xcrit);
%     N = N+1e6;
%     
%     clear urandom Xd_MC
% end


% Xcrit = 0.5:0.0001:0.52;
% for i = 1:length(Xcrit)
% 
%     FF(i) = (sum(Xd_MC <= Xcrit(i)) / length(Xd_MC))^(6*24*365*100);
% end

% figure; plot(Xcrit, FF)