clearvars
close all
clc

dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example');


tag = 'design_wind_speed';

figdir = strcat(cd,'\figures\',tag);
mkdir(figdir);

%% 100 year wind speed

Udesign = logninv(1-1/(365*24*6*100), 1.0967,0.4894);

% turbulence parameters

% take the most probable value
mu_dash1 = @(u) 0.122+0.039*u;
mu_dash2 = @(u) -0.657+0.03*u;
sigma_dash1 = 0.3159;
sigma_dash2 = 0.3021;

su_MPP = exp(mu_dash1(Udesign) - sigma_dash1^2);
sw_MPP = exp(mu_dash2(Udesign) - sigma_dash2^2);

%% calculate the RMS response

[ std,stddot ] = short_term_response( Udesign,su_MPP,sw_MPP );



%% extreme value

upcross = (1/2/pi)*stddot/std;

T = 600;
expected_max = std*(sqrt(2*log(upcross*T))+0.5772/(sqrt(2*log(upcross*T))));
