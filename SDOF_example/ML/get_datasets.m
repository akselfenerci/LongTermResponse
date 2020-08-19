clearvars
dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example\ML');

addpath('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example');


TTinv = @(u) transform_u_to_x( u );


%%

u1 = 0:0.5:5;
u2 = 1:0.5:5;
u3 = 1:0.5:5;
u4 = -2:0.1:5;

[U1,U2,U3,U4] = ndgrid(u1,u2,u3,u4);

U1vec = reshape(U1,[length(U1(:)),1]);
U2vec = reshape(U2,[length(U2(:)),1]);
U3vec = reshape(U3,[length(U3(:)),1]);
U4vec = reshape(U4,[length(U4(:)),1]);

xvals = TTinv([U1vec U2vec U3vec]);

U = xvals(:,1);
su = xvals(:,2);
sw = xvals(:,3);

[ std,stddot ] = short_term_response( U,su,sw );

Tshort = 600;
[ Xd ] = short_term_extreme_inv( std,stddot,Tshort,normcdf(U4vec) );

figure; plot(xvals(:,1),std,'x');
figure; plot(xvals(:,1),real(Xd),'x');

Input_Output = [U1vec U2vec U3vec U4vec Xd];

save('Dataset_unifromgrid','Input', 'Output');


%%

% Data = load('Dataset_unifromgrid');
% 
% Input = Data.Input;
% Output = Data.Output;

