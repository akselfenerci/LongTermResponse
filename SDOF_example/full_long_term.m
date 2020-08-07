
clearvars
close all
clc

dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example');

%% joint prob. density

sigmauvals = 0.01:0.05:8;
sigmawvals = 0.01:0.05:4.5;
Uvals = 0.01:0.05:40;

sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
rhoY = 0.8148;
fjoint_handle = joint_pdf_lognormal( sigma_dash, rhoY );

Updf = @(x) wblpdf(x,5.1941,1.7946);
[X,Y,Z] = meshgrid(Uvals,sigmauvals,sigmawvals);
joint_full_env = @(u,su,sw) fjoint_handle(su,sw,u)*Updf(u);
fturb = arrayfun(joint_full_env, X,Y,Z);

save('fturb','fturb');

%%

[ std,stddot ] = short_term_response( X,Y,Z );

Tshort = 600;
% resp = 0.01:0.2:3;

resp = 1;

for i = 1:length(resp)
    
    [ Fx_d ] = short_term_extreme( std,stddot,Tshort,resp(i) );
    
    [ Flong(i) ] = long_term_CDF( Uvals,sigmauvals,sigmawvals, fturb, Fx_d );
    
    Flong
end





%%



% for 10-mins, characteristic value of the 100 year extreme value
target_char = 1-1/(365*24*6);
cdf_mp = target_char^(365*24*6);
Tratio = (365*24*6);

Flong(Flong>1) = 1;

eps = 1e-3;
xx = resp_ini;
while abs(max(Flong(Flong<target_char))^Tratio - cdf_mp) > eps
    
    lower = Flong<target_char; [Flong_lower,ind_lower] = max(Flong(lower)); dummy = xx(lower); xx_lower = dummy(ind_lower);
    upper = Flong>=target_char; [Flong_upper,ind_upper] = min(Flong(upper)); dummy = xx(upper); xx_upper = dummy(ind_upper);
    
    
    ratio_step = (target_char - Flong_lower)/(1-Flong_lower);
    step = (xx_upper - xx_lower)*ratio_step;
    
    xx(end+1) = xx_lower + step;
    
    fun = @(x,y)  short_term_extreme( x,y,Tshort,xx(end) );
    Flong(end+1) = long_term_CDF( fun,Uvals,sigmauvals,sigmawvals,X,Y,Z,fturb,lmSTD,lmSTDdot );
    
    Flong
end
