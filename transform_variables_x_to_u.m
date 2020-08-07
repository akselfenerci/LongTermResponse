function [ u ] = transform_variables_x_to_u( xx,RSM )

% variables are U, sigmau, sigmaw and Xd


% rosenblatt transform

% U, mean speed
u1 = norminv(logncdf(xx(1),1.0967,0.4894));

% sigma u, turbulence
rhoY = 0.8148;
sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
[ fjoint_handle ] = joint_pdf_lognormal( sigma_dash, rhoY );

ints1 = 0.01:0.1:10;
ints2 = 0.01:0.1:xx(2);

[int1,int2] = meshgrid(ints1,ints2);

funcondturb = @(x1,x2) fjoint_handle(x1,x2,xx(1));
fcondturb = arrayfun(funcondturb,int1,int2);

Fx2 = trapz(ints2,trapz(ints1,fcondturb,2),1);
u2 = norminv(Fx2);

% sigma w, turbulence vertical
% rhoY = 0.8148;
% sigma_dash(1) = 0.3159;
% sigma_dash(2) = 0.3021;
% [ fjoint_handle ] = joint_pdf_lognormal( sigma_dash, rhoY );
cond_dist = @(x) fjoint_handle(xx(2),x,xx(1));
ints = linspace(0.001,xx(3),100);

Fx3 = trapz(ints,arrayfun(cond_dist,ints))/lognpdf(xx(2),0.122+0.039*xx(1),0.3159);
u3 = norminv(Fx3);

% Xd, short-term extreme response
Tshort = 600;
[std] = predict(RSM.lmSTD,xx(1:3));
[stddot] = predict(RSM.lmSTDdot,xx(1:3));
std(std<0) = 1e-5;
stddot(stddot<0) = 1e-5;
[ Fx_d ] = short_term_extreme( std,stddot,Tshort,xx(4) );
u4 = norminv(Fx_d);


u = [u1 u2 u3 u4];

end

