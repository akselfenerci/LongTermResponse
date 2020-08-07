function [ x ] = transform_variables_u_to_x( u,RSM )

% U, mean speed
x(1) =  icdf('Lognormal',normcdf(u(1)),1.0967,0.4894);

% sigma u, turbulence
% rhoY = 0.8148;
% sigma_dash(1) = 0.3159;
% sigma_dash(2) = 0.3021;
% [ fjoint_handle ] = joint_pdf_lognormal( sigma_dash, rhoY );
% 
% ints1 = 0.01:0.1:10;
% ints2 = @(x) 0.01:0.1:x;
% 
% int1 = @(x) get_int1(ints1,ints2(x));
% int2 = @(x) get_int2(ints1,ints2(x));
% 
% % [int1,int2] = meshgrid(ints1,ints2);
% 
% funcondturb = @(x1,x2) fjoint_handle(x1,x2,x(1));
% fcondturb = @(x) arrayfun(funcondturb,int1(x),int2(x));
% 
% funcmin = @(x) abs(trapz(ints2(x),trapz(ints1,fcondturb(x),2),1) - normcdf(u(2)));
% 
% x2s = 0.2:0.1:5;
% [~,idx] = min(arrayfun(funcmin,x2s));
% 
% x2s_new = x2s(idx)-0.01:0.0001:x2s(idx)+0.01;
% [~,idx] = min(arrayfun(funcmin,x2s));
% 
% x(2) = x2s_new(idx);


x(2) = icdf('Lognormal',normcdf(u(2)),0.122+0.039*x(1),0.3159);

% sigma w, turbulence vertical
rhoY = 0.8148;
sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
[ fjoint_handle ] = joint_pdf_lognormal( sigma_dash, rhoY );
cond_dist = @(xx) fjoint_handle(x(2),xx,x(1));


func = @(x3) abs(trapz(0.01:0.01:x3,arrayfun(cond_dist,0.01:0.01:x3))/lognpdf(x(2),0.122+0.039*x(1),0.3159)- normcdf(u(3))) ;
% func = @(x3) abs(trapz(0.01:0.01:x3,arrayfun(cond_dist,0.01:0.01:x3))- normcdf(u(3))) ;

x3s = 0.2:0.1:5;
[~,idx] = min(arrayfun(func,x3s));

x3s_new = x3s(idx)-0.01:0.0001:x3s(idx)+0.01;
[~,idx] = min(arrayfun(func,x3s_new));

x(3) = x3s_new(idx);


% Xd, short-term extreme response
Tshort = 600;
[std] = predict(RSM.lmSTD,x(1:3));
[stddot] = predict(RSM.lmSTDdot,x(1:3));
std(std<0) = 1e-5;
stddot(stddot<0) = 1e-5;

[ x(4) ] = short_term_extreme_inv( std,stddot,Tshort,normcdf(u(4)) );


end

