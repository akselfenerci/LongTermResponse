clear all
close all

dbstop if error

addpath('C:\Users\akselfe\Documents\GitHub\wawi');
cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse');

import wawi.*

% savepath = [cd '\Tests_state_space\OnlyAero\' ];

omegaGlobal = 0.0001:0.005:6;
settings.OmegaAxisGlobal = omegaGlobal;

% import user settings
settings = settings_AD(settings);
settings = settings_bridge(settings);
settings = settings_wind(settings);
settings = settings_hydro(settings);

save('settings','settings');

%% Import aerodynamic data

% adFits(1) = load(strcat(settings.AD.target,'\',settings.AD.target_name_AD));


%% Construct modal matrices for FEM model

phiphi=zeros(12,6);
for i = 1:6
    phiphi(i,i) = 1;
    phiphi(i+6,i) = 1;
end

MM = settings.bridge.MM;
KK = settings.bridge.KK;
CC = settings.bridge.CC;

for i = 1:6
    MM(i+6,i+6) = MM(i,i)/2;
    MM(i,i) = MM(i,i)/2;
    KK(i+6,i+6) = KK(i,i)/2;
    KK(i,i) = KK(i,i)/2;
    CC(i+6,i+6) = CC(i,i)/2;
    CC(i,i) = CC(i,i)/2;
end

genMs = phiphi'*MM*phiphi;
genKs = phiphi'*KK*phiphi;
genCs = phiphi'*CC*phiphi;


% Vref = settings.bridge.U;          % Mean wind velocity in reference point
% Xref = [0 0 0]';    % Position of reference point
% eV1 = [0 1 0]';             % Direction of mean wind velocity in global coordinates
% eV2tmp = -[1 1 0]';        % Vector in the eV1-eV2 plane
% eLe2 = [0, 1, 0];
% [TG2V] = wawi.misc.transform_unit(eV1, eV2tmp);       % Define the transformation matrix Global 2 local for the Mean wind
% 
% nodes = [1 0 0 10
%     2 1 0 10];
% elements = [1 1 2 1];
% TG2Le0 = wawi.misc.element_transform_matrices(elements, nodes, eLe2);

% wawi.plot.plotwindelements(figure(1), figure(2), nodes, elements, TG2Le0, TG2V)

phiAeroFull = phiphi;

B(:,:,1) = settings.bridge.B;
D(:,:,1) = settings.bridge.D;
loadCoeff = load(settings.bridge.loadcoeff);

adFun{1} = @(vRed)wawi.wind.adquasisteady(vRed,loadCoeff,B,D); 

%% freq-dep matrices

[ genCae, genKae ] = wawi.wind.compute_aero_matrices(omegaGlobal, Vref, Xref, adFun, nodes, elements, TG2Le0, TG2V, phiAeroFull, B, rho);

genMadd = zeros(size(genMs));
genCadd = -genCae;
genKadd = -genKae;


invH = wawi.pred.freq.frf(omegaGlobal, genMs, genCs, genKs, genMadd, genCadd, genKadd,false);

%% Eigenvalue solution
% Ktot = wawi.misc.matrixsum(genKs, genKadd);
% Ctot = wawi.misc.matrixsum(genCs, genCadd);
% Mtot = wawi.misc.matrixsum(genMs, genMadd);

% [lambda, psi] = wawi.eig.iteratemodes(Ktot, Ctot, Mtot, omegaGlobal);


%% wind action

% wind spectra & parameters
% parameters
z = 60; % Height above ground
A = [30 0 3]; % Coefficient in the one point spectra
sigma = [2 0 1]; % Standard deviation of turbulence 
C = [0 0 0; % Decay coefficient in Davenports exponential format 
    10 0 8;
    10 0 8];
vRef = 30; % Wind velocity
Sfun = @(w) wawi.wind.spectra.generic_Kaimal_matrix(w,z, nodes,Vref, Xref, TG2V, A , sigma, C);

genAeroSqSq = wawi.wind.windaction(omegaGlobal, Sfun, Vref, Xref, loadCoeff, nodes, elements, TG2Le0, TG2V, phiAeroFull, rho, B, D);


%% Total action

genSqSq = genAeroSqSq;

genSrSr = wawi.pred.freq.freqsim(invH, genSqSq,false);

std_lat = sqrt(trapz(omegaGlobal,squeeze(genSrSr(2,2,:))));
% std_vert = sqrt(trapz(omegaGlobal,squeeze(genSrSr(3,3,:))));
% std_tors = sqrt(trapz(omegaGlobal,squeeze(genSrSr(4,4,:))));
% 







