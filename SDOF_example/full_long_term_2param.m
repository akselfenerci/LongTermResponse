
clearvars
close all
clc

dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example');

turbint = 'off';

tag = 'full_long_term_two_parameters';

figdir = strcat(cd,'\figures\',tag);
mkdir(figdir);

savedir = strcat(cd,'\saved\',tag);
mkdir(savedir);


%% joint prob. density

sigmauvals = 0.001:0.01:15;
Uvals = 0.001:0.05:70;
% sigmauvals = 0.01:0.05:10;
% Uvals = 0.01:0.1:40;

sigma_dash = 0.3159;
mu_dash = @(u) 0.122+0.039*u;


Updflog = @(x) lognpdf(x,1.0967,0.4894);
fjoint_handle = @(u,su)  lognpdf(su,mu_dash(u),sigma_dash)*Updflog(u);

[X,Y] = meshgrid(Uvals,sigmauvals);

if strcmp(turbint,'off')
    load(strcat(savedir,'fturb_2param_highres.mat'));
else
    
    fturb = arrayfun(fjoint_handle, X,Y);
    
    save(strcat(savedir,'fturb_2param'),'fturb');
end



trapz(Uvals,trapz(sigmauvals,fturb,1),2)

%%

[ std,stddot ] = short_term_response( X,Y,3*ones(size(X)) );
Tshort = 600;




%%

resp = 0.001:0.01:0.5;

Flong = [];
for i = 1:length(resp)
    
    [ Fx_d ] = short_term_extreme( std,stddot,Tshort,resp(i) );
    
    [ Flong(i) ] = long_term_CDF_2param( Uvals,sigmauvals, fturb, Fx_d );
    
%     1-Flong
end

% Flong = 1-Flong;

%%



% for 10-mins, characteristic value of the N year extreme value
target_char = 1-1/(365*24*6);
cdf_mp = target_char^(365*24*6);
Tratio = (365*24*6);


eps = 1e-3;
xx = resp;
while abs(max(Flong(Flong<target_char))^Tratio - cdf_mp) > eps
    
    lower = Flong<target_char; [Flong_lower,ind_lower] = max(Flong(lower)); dummy = xx(lower); xx_lower = dummy(ind_lower);
    upper = Flong>=target_char; [Flong_upper,ind_upper] = min(Flong(upper)); dummy = xx(upper); xx_upper = dummy(ind_upper);
    
    
    ratio_step = (target_char - Flong_lower)/(1-Flong_lower);
    step = (xx_upper - xx_lower)*ratio_step;
    
    xx(end+1) = xx_lower + step;
    
    
    [ Fx_d ] = short_term_extreme( std,stddot,Tshort,xx(end) );
    [ Flong(end+1) ] = long_term_CDF_2param( Uvals,sigmauvals, fturb, Fx_d );
    
%     Flong(end) = 1-Flong(end);
    %     Flong
end

xx(end)

CDF.F = Flong(end);
CDF.x = xx(end);



%% plot the CDF

lower = linspace(0,xx(1),100);
upper = linspace(xx(end),xx(end)*10,100);

xaxis = [lower upper];

for i = 1:length(xaxis)
    
    [ Fx_d ] = short_term_extreme( std,stddot,Tshort,xaxis(i) );
    [ Flong_xaxis(i) ] = long_term_CDF_2param( Uvals,sigmauvals, fturb, Fx_d );
    
end


[F_plot,idx] = sort(horzcat(Flong, Flong_xaxis),'ascend');
x_plot = horzcat(xx,xaxis);
x_plot = x_plot(idx);

% 1 year
Tratio = 365*24*6;
fig = figure; 
plot(x_plot,F_plot.^Tratio,'-b');


% 50 years
figure(fig); 
hold on; grid on;
Tratio = 365*24*6*50;
plot(x_plot,F_plot.^Tratio,'--r');

% 100 years
figure(fig); 
hold on; grid on;
Tratio = 365*24*6*100;
plot(x_plot,F_plot.^Tratio,'.k');


h = gca;
h.XLim = [0 CDF.x*10];
h.FontSize = 12;
h.LineWidth = 1.5;
h.Children(1).LineWidth = 1.5;
h.Children(2).LineWidth = 1.5;
h.Children(3).LineWidth = 1.5;
h.YLabel.String = 'F_{R_{LT}|w}';
h.XLabel.String = 'R_{LT}';
legend('1-year','50-years','100 years');
savefig(strcat(figdir,'\','Full_long_term_2param_su.fig'));
saveas(gcf,strcat(figdir,'\','Full_long_term_2param_su.emf'));
close(gcf);


CDF.xplot = x_plot;
CDF.Fplot = F_plot;


% characteristic values
% 1 year
Tratio = 365*24*6;
[Fdummy,idx] = unique(F_plot.^Tratio);
xchar_1year = interp1(Fdummy,x_plot(idx),(1-1/Tratio)^Tratio);
% 50 year
Tratio = Tratio*50;
[Fdummy,idx] = unique(F_plot.^Tratio);
xchar_50year = interp1(Fdummy,x_plot(idx),(1-1/Tratio)^Tratio);
% 100 year
Tratio = Tratio*2;
[Fdummy,idx] = unique(F_plot.^Tratio);
xchar_100year = interp1(Fdummy,x_plot(idx),(1-1/Tratio)^Tratio);


CDF.xchar_1year = xchar_1year;
CDF.xchar_50year = xchar_50year;
CDF.xchar_100year = xchar_100year;

save(strcat(savedir,'CDF_full_long_term_2param'),'CDF');



%% contribution


[ Fx_d ] = short_term_extreme( std,stddot,Tshort,xchar_100year );
[ ~,contr ] = long_term_CDF_2param( Uvals,sigmauvals, fturb, Fx_d );

figure;
mesh(X,Y,contr./max(max(contr)));
view([0 0 1]);
colormap(jet);
colorbar;
h = gca;
h.YLabel.String = '\sigma_{u} (m/s)';
h.XLabel.String = 'U (m/s)';
h.XLim = [0 Inf];
h.YLim = [0 Inf];
h.FontSize = 12;
savefig(strcat(figdir,'\','Contribution2param_su.fig'));
saveas(gcf,strcat(figdir,'\','Contribution2param_su.emf'));
close(gcf);













