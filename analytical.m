


clearvars
close all
clc

dbstop if error

RSM = load('RSmodel.mat');

xx = [20 2 1 0.8];

sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
rhoY = 0.8148;
[ fjoint_handle ] = joint_pdf_lognormal( sigma_dash, rhoY );

u1 = norminv(logncdf(xx(1),1.0967,0.4894));


syms x y

fcond = int(fjoint_handle(x,y,xx(1)),y,0,10);

Fsu = double(int(fcond,x,0, xx(2)));

u2 = norminv(Fsu);

syms z

Fsw = double(int(fjoint_handle(xx(2),z,xx(1)),0, xx(3)));

u3 = norminv(Fsw);

% u4
Tshort = 600;
[std] = predict(RSM.lmSTD,xx(1:3));
[stddot] = predict(RSM.lmSTDdot,xx(1:3));
std(std<0) = 1e-5;
stddot(stddot<0) = 1e-5;
[ Fx_d ] = short_term_extreme( std,stddot,Tshort,xx(4) );
u4 = norminv(Fx_d);

%
u = [u1 u2 u3 u4];


%%

syms x y
fcond = int(fjoint_handle(x,y,xx(1)),y,0,10);

xf = 0.1:0.1:5;
for i = 1:length(xf)

x = 0.01:0.01:xf(i);
int(i) = trapz(x,double(subs(fcond)));

end

sigma = 0.3159;
mu = 0.122+0.039*xx(1);
p = logncdf(xf,mu,sigma);

%%

% transform back

% x1
xx2(1) =  icdf('Lognormal',normcdf(u(1)),1.0967,0.4894);

% x2
syms x y
fcond = int(fjoint_handle(x,y,xx2(1)),y,0,10);
Fsu = int(fcond,x,0, x);

xdummy = 0.01:0.1:10;
x = xdummy; 
Fsuvals_coarse = double(subs(Fsu));
[~,idx] = min(abs(Fsuvals_coarse - normcdf(u(2))));

xdummy2 = xdummy(idx)-0.01:0.0001:xdummy(idx)+0.01;
x = xdummy2;
Fsuvals_fine = double(subs(Fsu));
[~,idx] = min(abs(Fsuvals_fine - normcdf(u(2))));

xx2(2) = xdummy2(idx);


% x3
syms z
Fsw = int(fjoint_handle(xx2(2),z,xx2(1)),0, z);

zdummy = 0.01:0.1:5;
z = zdummy; 
Fswvals_coarse = double(subs(Fsw));
[~,idx] = min(abs(Fswvals_coarse - normcdf(u(3))));

zdummy2 = zdummy(idx)-0.01:0.0001:zdummy(idx)+0.01;
z = zdummy2;
Fswvals_fine = double(subs(Fsw));
[~,idx] = min(abs(Fswvals_fine - normcdf(u(2))));

xx2(3) = zdummy2(idx);

% x4
Tshort = 600;
[std] = predict(RSM.lmSTD,xx2(1:3));
[stddot] = predict(RSM.lmSTDdot,xx2(1:3));
std(std<0) = 1e-5;
stddot(stddot<0) = 1e-5;

[ xx2(4) ] = short_term_extreme_inv( std,stddot,Tshort,normcdf(u(4)) );
