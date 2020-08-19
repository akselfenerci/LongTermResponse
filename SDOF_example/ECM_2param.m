clearvars
close all
clc

dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example');


tag = 'ECM_2param';

figdir = strcat(cd,'\figures\',tag);
mkdir(figdir);

%%

Ftarget = 1-1/(365*24*6*100);
beta_target = norminv(Ftarget);

% u1vals = -beta_target:0.1:beta_target;
u1vals = [-beta_target:0.005:-4.8 -4.8:0.1:4.8 4.8:0.005:beta_target];
u2vals = sqrt(beta_target.^2 - u1vals.^2);

uu = [u1vals(:),u2vals(:); u1vals(:),-u2vals(:)];

figure; 
plot(uu(:,1),uu(:,2),'b.'); 
grid on;
h = gca;
h.LineWidth = 1.5;
h.FontSize = 12;
h.XLabel.String = 'u_{1}';
h.YLabel.String = 'u_{2}';
h.Children.MarkerSize = 8;
legend(strcat('\beta = ', num2str(beta_target)) );
fig = gcf;
width = fig.Position(4);
fig.Position = [fig.Position(1:2) width width];
savefig(strcat(figdir,'\','Ucircle.fig'));
saveas(gcf,strcat(figdir,'\','Ucircle.emf'));
close(gcf);


%% transform to actual variable space

x1 = arrayfun(@(x) logninv(x,1.0967,0.4894),arrayfun(@normcdf,uu(:,1)));

sigma_dash = 0.3159;
mu_dash1 = @(u) 0.122+0.039*u;

x2 = arrayfun(@(x,mu) logninv(x,mu,sigma_dash),arrayfun(@normcdf,uu(:,2)),arrayfun(mu_dash1,x1));

fig = figure; 
plot(x1,x2,'b.');
grid on; hold on;
h = gca;
h.LineWidth = 1.5;
h.FontSize = 12;
h.XLabel.String = 'U (m/s)';
h.YLabel.String = '\sigma_{u}';
h.YLim = [0 8];
h.Children.MarkerSize = 8;

% design point
hh = plot(32.8,6.03,'kd');
hh.MarkerSize = 8;
hh.LineWidth = 2;
legend(hh,'design point (FORM)')





%% 

% take an arbitrary value for sw, normally it should be the median but that
% is hard
    

[ std,stddot ] = short_term_response( x1,x2,2*ones(size(x1)) );

[~,idx] = max(std);

figure(fig);
hh = plot(x1(idx),x2(idx),'rp');
hh.MarkerSize = 8;
hh.LineWidth = 2;
h.Legend.String{2} = 'ECM';
savefig(strcat(figdir,'\','contour_U_su.fig'));
saveas(gcf,strcat(figdir,'\','contour_U_su.emf'));
close(gcf);


Tshort = 600;
[ x_05 ] = short_term_extreme_inv( std(idx),stddot(idx),Tshort,0.5 );

[ x_09 ] = short_term_extreme_inv( std(idx),stddot(idx),Tshort,0.9 );





