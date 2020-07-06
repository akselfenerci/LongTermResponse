function [ settings ] = settings_wind( settings )

% user settings concerning the wind 

settings.wind.button_ex = 'on';

% settings.wind.Au = 20;
% settings.wind.Aw = 3;
% settings.wind.sigmau = 4;
% settings.wind.sigmaw = 2;

settings.wind.U = settings.bridge.U;
% settings.wind.U = 32;

settings.wind.Au = 10;
settings.wind.Aw = 1.15;
settings.wind.sigmau = settings.wind.U*0.1448;
settings.wind.sigmaw = settings.wind.U*0.0724;

settings.wind.z = 68;


% settings.wind.omegaaxis = linspace(0.000001,6,1000);
settings.wind.omegaaxis = settings.OmegaAxisGlobal;


% settings.wind.buffeting_file = 'BuffetingLoad_Amplitude';

settings.wind.saveloc = 'C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\Time_dom_simulation\SimpleStudy';
settings.wind.filename = 'simTurbulence';

settings.wind.sim.Nsim = 10;
settings.wind.simLen = 3*6000; % seconds


end

