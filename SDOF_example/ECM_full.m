
clearvars
close all
clc

dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example');

turbint = 'off';

tag = 'ECM';

figdir = strcat(cd,'\figures\',tag);
mkdir(figdir);


%%

Ftarget = 1-1/(100*365*24*6);
beta_target = norminv(Ftarget);

[uu1,uu2,uu3] = sphere(100);
uu1 = uu1*beta_target;
uu2 = uu2*beta_target;
uu3 = uu3*beta_target;

figure; 
mesh(uu1,uu2,uu3);
colormap(gray);
grid on;
h = gca;
h.LineWidth = 1.5;
h.FontSize = 12;
h.XLabel.String = 'u_{1}';
h.YLabel.String = 'u_{2}';
h.ZLabel.String = 'u_{3}';
h.XLim = [-6 6];
h.YLim = [-6 6];
h.ZLim = [-6 6];
fig = gcf;
width = fig.Position(4);
fig.Position = [fig.Position(1:2) width width];
savefig(strcat(figdir,'\','Usphere.fig'));
saveas(gcf,strcat(figdir,'\','Usphere.emf'));
close(gcf);


%% transform to actual variable space

TTinv = @(u) transform_u_to_x(u);

xcell = arrayfun(@(x,y,z) TTinv([x y z]), uu1, uu2, uu3,'UniformOutput', 0);

xx1 = cell2mat(cellfun(@(x) x(1), xcell,'UniformOutput', 0));
xx2 = cell2mat(cellfun(@(x) x(2), xcell,'UniformOutput', 0));
xx3 = cell2mat(cellfun(@(x) x(3), xcell,'UniformOutput', 0));


figure; 
mesh(xx1,xx2,xx3);
colormap([0  0  0]);
grid on;
h = gca;
h.LineWidth = 1.5;
h.FontSize = 12;
h.XLabel.String = 'U (m/s)';
h.YLabel.String = '\sigma_{u} (m/s)';
h.ZLabel.String = '\sigma_{w} (m/s)';
fig = gcf;
width = fig.Position(4);
fig.Position = [fig.Position(1:2) width width];
savefig(strcat(figdir,'\','ContourSurface3D.fig'));
saveas(gcf,strcat(figdir,'\','ContourSurface3D.emf'));
close(gcf);


%% find the point which gives the maximum RMS response

TT = @(x) transform_x_to_u( x );

% optimization? 
options = optimoptions(@fmincon,...
    'Display','iter','Algorithm','sqp');

obj_fun = @(w) -short_term_response( w(1),w(2),w(3) );

candidates = find(xx1 > 20 & xx1 < 25 & xx2 > 3 & xx3 > 1 );
w0 = [xx1(candidates(1)) xx2(candidates(1)) xx3(candidates(1))];

limit_state = @(w) limit_state_ECM(TT(w),beta_target);

problem = createOptimProblem('fmincon','x0',w0,...
    'objective',obj_fun,...
    'nonlcon',limit_state,...
    'options',options);
gs = GlobalSearch;

wopt = run(gs,problem);


%%


figure; 
mesh(xx1,xx2,xx3);
colormap([0  0  0]);
view([0 0 1]);
grid on;
h = gca;
h.LineWidth = 1.5;
h.FontSize = 12;
h.XLabel.String = 'U (m/s)';
h.YLabel.String = '\sigma_{u} (m/s)';
hold on;
hh = plot3(wopt(1),wopt(2),10,'rp'); % z is arbitrary and high - so that the star is in the front 
hh.MarkerSize = 8;
hh.LineWidth = 2;
savefig(strcat(figdir,'\','ContourSurface_projection1.fig'));
saveas(gcf,strcat(figdir,'\','ContourSurface_projection1.emf'));
close(gcf);

figure; 
mesh(xx1,xx2,xx3);
colormap([0  0  0]);
view([0 -1 0]);
grid on;
h = gca;
h.LineWidth = 1.5;
h.FontSize = 12;
h.XLabel.String = 'U (m/s)';
h.ZLabel.String = '\sigma_{w} (m/s)';
hold on;
hh = plot3(wopt(1),-10,wopt(3),'rp'); % z is arbitrary and high - so that the star is in the front 
hh.MarkerSize = 8;
hh.LineWidth = 2;
savefig(strcat(figdir,'\','ContourSurface_projection2.fig'));
saveas(gcf,strcat(figdir,'\','ContourSurface_projection2.emf'));
close(gcf);


%% extreme response

[ std,stddot ] = short_term_response( wopt(1),wopt(2),wopt(3) );


Tshort = 600;
[ x_05 ] = short_term_extreme_inv( std,stddot,Tshort,0.5 );

[ x_09 ] = short_term_extreme_inv( std,stddot,Tshort,0.9 );

















































