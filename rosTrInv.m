function [ xx ] = rosTrInv( u,varargin )

if length(u) > 3
    if nargin >1
        RSM = varargin{1};
    else
        error('RSM model needed!');
    end
end

    
xx(1) =  icdf('Lognormal',normcdf(u(1)),1.0967,0.4894);

% x2

xx(2) =  icdf('Lognormal',normcdf(u(2)),0.122+0.039*xx(1),0.3159);

% xx(2) =  icdf('Lognormal',normcdf(u(2)),-0.657+0.03*xx(1),0.3021);

% x3
sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
rhoY = 0.8148;
mu_dash(1) = 0.122+0.039*xx(1);
mu_dash(2) = -0.657+0.03*xx(1);
v = sqrt((exp(sigma_dash.^2)-1).*exp(2.*mu_dash+sigma_dash));
m = exp(mu_dash+sigma_dash./2);
covX = log(rhoY*v(1)*v(2)/(m(1)*m(2))+1);
rhoX = covX/sigma_dash(1)/sigma_dash(2);

[ fjoint_handle ] = joint_pdf_lognormal( sigma_dash, rhoX );

ff = @(x) fjoint_handle(xx(2),x,xx(1));
Fsw = @(x) trapz(0.001:0.001:x,arrayfun(ff,0.001:0.001:x))/lognpdf(xx(2),0.122+0.039*xx(1),0.3159);
Fminimize = @(x) abs(Fsw(x) - normcdf(u(3)));

% options = optimset('TolX',1e-8,'TolFun',1e-8,'Display','iter','FunValCheck','on','MaxFunEvals',500,'MaxIter',500,'PlotFcns','optimplotfval');
% options = optimset('TolX',1e-4,'TolFun',1e-4,'MaxFunEvals',2e3,'MaxIter',2e3);
upper = 5;
fval = 1;
while fval > 0.01
%     [xx(3),fval] = fminbnd(Fminimize,0,upper,options);
    [xx(3),fval] = fminbnd(Fminimize,0,upper);
    upper = upper - 0.5;
end

% fval

if nargin > 1
    % x4
    Tshort = 600;
    [std] = predict(RSM.lmSTD,xx(1:3));
    [stddot] = predict(RSM.lmSTDdot,xx(1:3));
    std(std<0) = 1e-5;
    stddot(stddot<0) = 1e-5;
    
    [ xx(4) ] = short_term_extreme_inv( std,stddot,Tshort,normcdf(u(4)) );
end


end

