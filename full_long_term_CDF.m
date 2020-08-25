clear all
close all





%
sigmauvals = 0.01:0.05:10;
sigmawvals = 0.01:0.05:6;
U = 10;
sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
rhoY = 0.8148;

fjoint_handle = joint_pdf_lognormal( sigma_dash, rhoY );

[XX,YY] = meshgrid(sigmauvals,sigmawvals);
ft = arrayfun(fjoint_handle, XX,YY, repmat(U,size(XX)));

trapz(sigmauvals,trapz(sigmawvals,ft,1),2)

figure;
mesh(XX,YY,ft);
view([1.3 1 2.2]);
h = gca;
h.ZLabel.String = 'Prob. dens';


Uvals = 0.01:0.1:40;
Updf = @(x) lognpdf(x,1.0967,0.4894);
[X,Y,Z] = meshgrid(Uvals,sigmauvals,sigmawvals);
joint_full_env = @(u,su,sw) fjoint_handle(su,sw,u)*Updf(u);
fturb = arrayfun(joint_full_env, X,Y,Z);

trapz(Uvals,trapz(sigmauvals,trapz(sigmawvals,fturb,3),1),2)

[XX,YY] = meshgrid(Uvals,sigmauvals);
figure;
mesh(XX,YY,trapz(sigmawvals,fturb,3));
h = gca;
h.YLabel.String = '\sigma_{u} (m/s)';
h.YLim = [-Inf 4];
h.XLabel.String = 'U (m/s)';
h.XLim = [-Inf 15];
h.ZLabel.String = 'Prob. density ';


[XX,YY] = meshgrid(sigmawvals,sigmauvals);
figure;
mesh(XX,YY,squeeze(trapz(Uvals,fturb,2)));
view([1.3 1 2.2]);
h = gca;
h.YLabel.String = '\sigma_{u} (m/s)';
h.YLim = [-Inf 4];
h.XLabel.String = '\sigma_{w} (m/s)';
h.XLim = [-Inf 2];
h.ZLabel.String = 'Prob. ';

[XX,YY] = meshgrid(sigmawvals,Uvals);
figure;
mesh(XX,YY,squeeze(trapz(sigmauvals,fturb,1)));
view([1.3 1 2.2]);
h = gca;
h.YLabel.String = 'U (m/s)';
h.YLim = [-Inf 15];
h.XLabel.String = '\sigma_{w} (m/s)';
h.XLim = [-Inf 2];
h.ZLabel.String = 'Prob. ';

load('RSmodel');
Tshort = 600;

% resp_ini = 0.01:0.2:3;
resp_ini = 1.039;

for i = 1:length(resp_ini)
    
    fun = @(x,y)  short_term_extreme( x,y,Tshort,resp_ini(i) );
    
    [ Flong(i) ] = long_term_CDF( fun,Uvals,sigmauvals,sigmawvals,X,Y,Z,fturb,lmSTD,lmSTDdot );
    
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





