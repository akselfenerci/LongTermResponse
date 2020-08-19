

clearvars
close all
clc

dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example');


TT = @(x) transform_x_to_u( x );
TTinv = @(u) transform_u_to_x( u );


tag = 'form';

figdir = strcat(cd,'\figures\',tag);
mkdir(figdir);



%%


x0 = [18 2 1 0.1];


xrange = linspace(0.2,2.5,100);

xrange = horzcat(linspace(0.05,0.2,10),xrange);

for i = 1:length(xrange)
    [ Fx(i) ] = form_CDF_value( xrange(i),x0,TT );
end



% 1 year
Tratio = 365*24*6;
fig = figure; 
plot(xrange,Fx.^Tratio,'-b');

% 50 years
figure(fig); 
hold on; grid on;
Tratio = 365*24*6*50;
plot(xrange,Fx.^Tratio,'--r');

% 100 years
figure(fig); 
hold on; grid on;
Tratio = 365*24*6*100;
plot(xrange,Fx.^Tratio,'.k');


h = gca;
h.XLim = [0 2.5];
h.FontSize = 12;
h.LineWidth = 1.5;
h.Children(1).LineWidth = 1.5;
h.Children(2).LineWidth = 1.5;
h.Children(3).LineWidth = 1.5;
h.YLabel.String = 'F_{R_{LT}|w}';
h.XLabel.String = 'R_{LT}';
legend('1-year','50-years','100 years');
savefig(strcat(figdir,'\','FORM_cdf.fig'));
saveas(gcf,strcat(figdir,'\','FORM_cdf.emf'));
close(gcf);


%% characteristic value

Tratio = 365*24*6*100;
[Fdummy,idx] = unique(Fx.^Tratio);
xchar_100year = interp1(Fdummy,xrange(idx),(1-1/Tratio)^Tratio);

[ Fx_actual,MPP ] = form_CDF_value( xchar_100year,x0,TT );

MPPu = TT(MPP);

%% limit state surface

u1vals = -2:0.1:7;
u2vals = -2:0.1:7;

[U1,U2] = meshgrid(u1vals,u2vals);

U3 = MPPu(3)*ones(size(U1));

[dummy] = arrayfun(@(x,y,z) TTinv([x y z]), U1,U2,U3,'UniformOutput',0);

celldummy = cellfun(@(x) TT([x MPP(4)]), dummy,'UniformOutput',0);

U4 = cell2mat(cellfun(@(x) x(4), celldummy,'UniformOutput',0));

figure; 
mesh(U1,U2,U4)
hold on;
plot3(MPPu(1),MPPu(2),MPPu(4),'p');
h = gca;
view([-1 -1 1 ]);
h.XLim = [-2 10];
h.YLim = [-2 10];
h.ZLim = [-10 10];
h.XLabel.String = 'u_{1} ';
h.YLabel.String = 'u_{2} ';
h.ZLabel.String = 'u_{4} ';
h.FontSize = 12;
h.LineWidth = 1.5;
savefig(strcat(figdir,'\','limitsurface.fig'));
saveas(gcf,strcat(figdir,'\','limitsurface.emf'));
close(gcf);



























