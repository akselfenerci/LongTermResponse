clearvars
clc
close all

tag = 'short_term_response';

figdir = strcat(cd,'\figures\',tag);
mkdir(figdir);

sigmauvals = 0.01:0.2:8;
sigmawvals = 0.01:0.2:4.5;
Uvals = 0.01:0.5:40;


%% short term RMS response


[XX,YY] = meshgrid(Uvals,sigmauvals);
[ std,stddot ] = short_term_response( XX,2*ones(size(XX)),YY );

figure;
surf(XX,YY,std);
h = gca;
h.YLabel.String = '\sigma_{u} (m/s)';
h.XLabel.String = 'U (m/s)';
h.ZLabel.String = '\sigma_{x} (m)';
h.FontSize = 12;
view([1 1 -1]);
h.YLim = [-Inf Inf];
h.ZLim = [0 Inf];
savefig(strcat(figdir,'\','RMS_disp_u.fig'));
saveas(gcf,strcat(figdir,'\','RMS_disp_u.emf'));
close(gcf);

figure;
surf(XX,YY,stddot);
h = gca;
h.YLabel.String = '\sigma_{u} (m/s)';
h.XLabel.String = 'U (m/s)';
h.ZLabel.String = '\sigma_{xdot} (m)';
h.FontSize = 12;
view([1 1 -1]);
h.YLim = [-Inf Inf];
h.ZLim = [0 Inf];
savefig(strcat(figdir,'\','RMS_vel_u.fig'));
saveas(gcf,strcat(figdir,'\','RMS_vel_u.emf'));
close(gcf);

[XX,YY] = meshgrid(Uvals,sigmawvals);
[ std,stddot ] = short_term_response( XX,YY,4*ones(size(XX)) );

figure;
surf(XX,YY,std);
h = gca;
h.YLabel.String = '\sigma_{w} (m/s)';
h.XLabel.String = 'U (m/s)';
h.ZLabel.String = '\sigma_{x} (m)';
h.FontSize = 12;
view([1 1 -1])
h.YLim = [-Inf Inf];
h.ZLim = [0 Inf];
savefig(strcat(figdir,'\','RMS_disp_w.fig'));
saveas(gcf,strcat(figdir,'\','RMS_disp_w.emf'));
close(gcf);

figure;
surf(XX,YY,stddot);
h = gca;
h.YLabel.String = '\sigma_{w} (m/s)';
h.XLabel.String = 'U (m/s)';
h.ZLabel.String = '\sigma_{xdot} (m)';
h.FontSize = 12;
view([1 1 -1]);
h.YLim = [-Inf Inf];
h.ZLim = [0 Inf];
savefig(strcat(figdir,'\','RMS_vel_w.fig'));
saveas(gcf,strcat(figdir,'\','RMS_vel_w.emf'));
close(gcf);















