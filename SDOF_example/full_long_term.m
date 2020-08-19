
clearvars
close all
clc

dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example');

turbint = 'off';

tag = 'full_long_term';

figdir = strcat(cd,'\figures\',tag);
mkdir(figdir);

savedir = strcat(cd,'\saved\',tag);
mkdir(savedir);

%% joint prob. density

sigmauvals = 0.01:0.05:15;
sigmawvals = 0.01:0.05:8;
Uvals = 0.01:0.1:70;

sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
rhoY = 0.8148;
fjoint_handle = joint_pdf_lognormal( sigma_dash, rhoY );

Updflog = @(x) lognpdf(x,1.0967,0.4894);
% Updf = @(x) wblpdf(x,5.1941,1.7946); % Weibull is harder to integrate
% numerically

[X,Y,Z] = meshgrid(Uvals,sigmauvals,sigmawvals);

if strcmp(turbint,'off')
    load(strcat(savedir,'fturb_3param.mat'));
else
    
    joint_full_env = @(u,su,sw) fjoint_handle(su,sw,u)*Updflog(u);
    fturb = arrayfun(joint_full_env, X,Y,Z);
    
    save(strcat(savedir,'fturb'),'fturb');
end

trapz(Uvals,trapz(sigmauvals,trapz(sigmawvals,fturb,3),1),2)


%%

[ std,stddot ] = short_term_response( X,Y,Z );
Tshort = 600;


%%

resp = 0.001:0.01:0.5;

Flong = [];
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


eps = 1e-3;
xx = resp;
while abs(max(Flong(Flong<target_char))^Tratio - cdf_mp) > eps
    
    lower = Flong<target_char; [Flong_lower,ind_lower] = max(Flong(lower)); dummy = xx(lower); xx_lower = dummy(ind_lower);
    upper = Flong>=target_char; [Flong_upper,ind_upper] = min(Flong(upper)); dummy = xx(upper); xx_upper = dummy(ind_upper);
    
    
    ratio_step = (target_char - Flong_lower)/(1-Flong_lower);
    step = (xx_upper - xx_lower)*ratio_step;
    
    xx(end+1) = xx_lower + step;
    
    
    [ Fx_d ] = short_term_extreme( std,stddot,Tshort,xx(end) );
    [ Flong(end+1) ] = long_term_CDF( Uvals,sigmauvals,sigmawvals, fturb, Fx_d );
    
    %     Flong
end

xx(end)

CDF.F = Flong(end);
CDF.x = xx(end);






%% plot the CDF

lower = linspace(0,xx(1),10);
upper = linspace(xx(end),xx(end)*10,100);

xaxis = [lower upper];

for i = 1:length(xaxis)
    
    [ Fx_d ] = short_term_extreme( std,stddot,Tshort,xaxis(i) );
    [ Flong_xaxis(i) ] = long_term_CDF( Uvals,sigmauvals,sigmawvals, fturb, Fx_d );
    
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
savefig(strcat(figdir,'\','Full_long_term.fig'));
saveas(gcf,strcat(figdir,'\','Full_long_term.emf'));
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


save(strcat(savedir,'CDF_full_long_term'),'CDF');


%% contribution


[ Fx_d ] = short_term_extreme( std,stddot,Tshort,xchar_100year );
[ ~,cont1,cont2,contfull ] = long_term_CDF( Uvals,sigmauvals,sigmawvals, fturb, Fx_d );

figure;
[XX,YY] = meshgrid(Uvals,sigmauvals);
mesh(XX,YY,cont1./max(cont1(:)));
view([0 0 1]);
colormap(jet);
colorbar;
h = gca;
h.YLabel.String = '\sigma_{u} (m/s)';
h.XLabel.String = 'U (m/s)';
h.XLim = [0 Inf];
h.YLim = [0 Inf];
h.FontSize = 12;
savefig(strcat(figdir,'\','Contributionu.fig'));
saveas(gcf,strcat(figdir,'\','Contributionu.emf'));
close(gcf);

figure;
[XX,YY] = meshgrid(Uvals,sigmawvals);
mesh(XX,YY,cont2'./max(cont2(:)));
view([0 0 1]);
colormap(jet);
colorbar;
h = gca;
h.YLabel.String = '\sigma_{w} (m/s)';
h.XLabel.String = 'U (m/s)';
h.XLim = [0 Inf];
h.YLim = [0 Inf];
h.FontSize = 12;
savefig(strcat(figdir,'\','Contributionw.fig'));
saveas(gcf,strcat(figdir,'\','Contributionw.emf'));
close(gcf);


[~,idx] = max(contfull(:));

X(idx)
Y(idx)
Z(idx)



























