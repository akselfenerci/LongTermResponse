clear all
close all

% profile on

load('RSmodel');

Uvals = 0.1:1:50;
sigmauvals = 0.1:0.05:10;
sigmawvals = 0.1:0.05:10;

sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
rhoY = 0.8148;

[X,Y,Z] = meshgrid(sigmauvals,Uvals,sigmawvals);

y_cell = cellfun(@(x,y) [x,y], num2cell(X), num2cell(Z),'UniformOutput',0);

mu_dash_cell = cellfun(@(x,y) [x,y], num2cell(0.122+0.039*Y), num2cell(-0.657+0.03*Y),'UniformOutput',0);
U_cell = num2cell(Y);

fun_full_env = @(y_fun,mu_dash_fun,u_fun) joint_pdf_turbulence( y_fun, mu_dash_fun, sigma_dash, rhoY )*lognpdf(u_fun,1.0967,0.4894);

joint_full_env = cellfun(fun_full_env, y_cell,mu_dash_cell, U_cell);

Tshort = 600;

resp_ini = 10;

for i = 1:length(resp_ini)
    
    fun = @(x,y)  short_term_extreme( x,y,Tshort,resp_ini(i) );
    
    [ Flong(i) ] = long_term_CDF( fun,Uvals,sigmauvals,sigmawvals,X,Y,Z,joint_full_env,lmSTD,lmSTDdot );
    
    Flong
end

%%

Uvals = 0.1:0.05:25;
sigmauvals = 0.1:0.1:5;
sigmawvals = 0.1:0.1:3;
sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
rhoY = 0.8148;
[X,Y,Z] = meshgrid(sigmauvals,Uvals,sigmawvals);
y_cell = cellfun(@(x,y) [x,y], num2cell(X), num2cell(Z),'UniformOutput',0);
mu_dash_cell = cellfun(@(x,y) [x,y], num2cell(0.122+0.039*Y), num2cell(-0.657+0.03*Y),'UniformOutput',0);
U_cell = num2cell(Y);
fun_full_env = @(y_fun,mu_dash_fun,u_fun) joint_pdf_turbulence( y_fun, mu_dash_fun, sigma_dash, rhoY )*lognpdf(u_fun,1.0967,0.4894);
joint_full_env = cellfun(fun_full_env, y_cell,mu_dash_cell, U_cell);

[XX,YY] = meshgrid(sigmauvals,Uvals);
figure;
mesh(XX,YY,trapz(sigmawvals,joint_full_env,3));
view([1.3 1 2.2]);
h = gca;
h.XLabel.String = '\sigma_{u} (m/s)';
h.YLabel.String = 'U (m/s)';
h.ZLabel.String = 'Prob. ';

[XX,YY] = meshgrid(sigmawvals,sigmauvals);
figure;
mesh(XX,YY,squeeze(trapz(Uvals,joint_full_env,1)));
view([1.3 1 2.2]);
h = gca;
h.ZLabel.String = 'Prob. ';

[XX,YY] = meshgrid(sigmawvals,Uvals);
figure;
mesh(XX,YY,squeeze(trapz(sigmauvals,joint_full_env,2)));
view([1.3 1 2.2]);
h = gca;
h.ZLabel.String = 'Prob. ';

trapz(Uvals,trapz(sigmauvals,trapz(sigmawvals,joint_full_env,3),2),1)


%%


% for 10-mins, characteristic value of the 100 year extreme value
target_char = 1-1/(365*24*6);
cdf_mp = target_char^(365*24*6);
Tratio = (365*24*6);

Flong(Flong>1) = 1;

eps = 1e-3;
xx = resp_ini;
while abs(max(Flong(Flong<1))^Tratio - cdf_mp) > eps
    
    lower = Flong<1; [Flong_lower,ind_lower] = max(Flong(lower)); dummy = xx(lower); xx_lower = dummy(ind_lower);
    upper = Flong>=1; [Flong_upper,ind_upper] = min(Flong(upper)); dummy = xx(upper); xx_upper = dummy(ind_upper);
    
    
    ratio_step = (target_char - Flong_lower)/(1-Flong_lower);
    step = (xx_upper - xx_lower)*ratio_step;
           
    xx(end+1) = xx_lower + step;
    
    LTfun = @(x,y,z,v) LTint_RSM(x,y,z,xx(end),lmSTD,lmSTDdot,v);
    Flong(end+1) = long_term_CDF( LTfun,Uvals,sigmauvals,sigmawvals,X,Y,Z,joint_full_env ); 
    
    Flong
end




% profile viewer
