function [ settings ] = settings_bridge( settings )

% user settings concerning the bridge 

settings.bridge.B = 31;
settings.bridge.D = 3.2;
settings.bridge.dL = 1; % element length
settings.bridge.rho = 1.22;
settings.bridge.U = 30;
% settings.bridge.U = 0;
settings.bridge.strdamping = 0.01;
% settings.bridge.omegaomega = [0.1 0 0; 0 0.2 0; 0 0 0.278].*2.*pi;


settings.bridge.omegaomega = zeros(6,6);
settings.bridge.omegaomega(2,2) = 0.1; % in Hz
settings.bridge.omegaomega(3,3) = 0.2;
settings.bridge.omegaomega(4,4) = 0.278;
settings.bridge.omegaomega(1,1) = 0.3;
settings.bridge.omegaomega(5,5) = 0.4;
settings.bridge.omegaomega(6,6) = 0.5;
settings.bridge.omegaomega = settings.bridge.omegaomega.*2.*pi; % in rad/s


settings.bridge.loadcoeff = 'LoadCoeff_B.txt';
settings.bridge.admittance = '';

settings.bridge.MM = zeros(6,6);
settings.bridge.MM(1,1) = 22740;
settings.bridge.MM(2,2) = 22740;
settings.bridge.MM(3,3) = 22740;
settings.bridge.MM(4,4) = 2.47*1e6;
settings.bridge.MM(5,5) = 2.47*1e6;
settings.bridge.MM(6,6) = 2.47*1e6;

% settings.bridge.MM = settings.bridge.MM.*1e3;

settings.bridge.CC = 2*settings.bridge.strdamping.*settings.bridge.omegaomega.*settings.bridge.MM;
settings.bridge.KK = settings.bridge.omegaomega.^2.*settings.bridge.MM;


end

