function [ settings ] = settings_bridge( settings )

% user settings concerning the bridge 

settings.bridge.B = 31;
settings.bridge.D = 3.2;
settings.bridge.dL = 1; % element length
settings.bridge.rho = 1.22;
% settings.bridge.U = 30;
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


settings.bridge.Xref = [0 0 0]';    % Position of reference point
eV1 = [0 1 0]';             % Direction of mean wind velocity in global coordinates
eV2tmp = -[1 1 0]';        % Vector in the eV1-eV2 plane
settings.bridge.eLe2 = [0, 1, 0];
settings.bridge.TG2V = wawi.misc.transform_unit(eV1, eV2tmp);       % Define the transformation matrix Global 2 local for the Mean wind

settings.bridge.nodes = [1 0 0 10
    2 1 0 10];
settings.bridge.elements = [1 1 2 1];
settings.bridge.TG2Le0 = wawi.misc.element_transform_matrices(settings.bridge.elements, settings.bridge.nodes, settings.bridge.eLe2);


end

