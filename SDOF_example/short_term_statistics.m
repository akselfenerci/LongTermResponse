clearvars
clc


tag = 'short_term_statistics';

figdir = strcat(cd,'\figures\',tag);
mkdir(figdir);



%%
Tshort = 600;

% given a wind field
U = 20;
su = 4;
sw = 2;

% short term RMS response
[ std,stddot ] = short_term_response( U,su,sw );

% short term extreme response
x = 0.1:0.01:0.5;
[ Fx_10min ] = short_term_extreme( std,stddot,Tshort,x );




%%

% plot sort term extreme response CDF
figure; 
plot(x,Fx_10min);
h = gca;
h.YLabel.String = 'F_{R_{max}|w}';
h.XLabel.String = 'R_{max}';
h.YLim = [0 1];
h.FontSize = 12;
h.LineWidth = 2;
grid on;
h.Children.LineWidth = 2;
savefig(strcat(figdir,'\','short_term_extreme_CDF.fig'));
saveas(gcf,strcat(figdir,'\','short_term_extreme_CDF.emf'));
close(gcf);



