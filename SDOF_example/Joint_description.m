clear all
close all

tag = 'joint_description';

figdir = strcat(cd,'\figures\',tag);
mkdir(figdir);

%
sigmauvals = 0.01:0.05:10;
sigmawvals = 0.01:0.05:6;
sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
rhoY = 0.8148;

fjoint_handle = joint_pdf_lognormal( sigma_dash, rhoY );


% Joint probability given a wind speed of 10 m/s
U = 10;
mu_dash1 = @(u) 0.122+0.039*u;
mu_dash2 = @(u) -0.657+0.03*u;
mu_dash = [mu_dash1(U) mu_dash2(U)];
[XX,YY] = meshgrid(sigmauvals,sigmawvals);
ft = arrayfun(fjoint_handle, XX,YY, repmat(U,size(XX)));

trapz(sigmauvals,trapz(sigmawvals,ft,1),2);

figure;
mesh(XX,YY,ft);
view([1.3 1 2.2]);
h = gca;
h.ZLabel.String = 'Prob. dens';
h.YLabel.String = '\sigma_{w} (m/s)';
h.YLim = [-Inf 3];
h.XLabel.String = '\sigma_{u} (m/s)';
h.XLim = [-Inf 6];
h.ZLabel.String = 'Prob. density ';
h.FontSize = 12;
view([1 1 1]);
savefig(strcat(figdir,'\','Prob_u_and_w_givenU.fig'));

%%

Uvals = 0.01:0.1:25;
Updf = @(x) wblpdf(x,5.1941,1.7946);
figure; 
plot(Uvals,Updf(Uvals));
h = gca;
h.YLabel.String = 'Prob. density';
h.XLabel.String = 'U (m/s)';
h.FontSize = 12;
savefig(strcat(figdir,'\','Pdf_U.fig'));


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
view([1 1 1]);
h.FontSize = 12;
savefig(strcat(figdir,'\','jointPdf_U_su.fig'));




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
view([1 1 1]);
h.FontSize = 12;
savefig(strcat(figdir,'\','jointPdf_su_sw.fig'));


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
view([1 1 1]);
h.FontSize = 12;
savefig(strcat(figdir,'\','jointPdf_U_sw.fig'));

