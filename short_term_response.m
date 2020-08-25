function [ std,stddot ] = short_term_response( settings,wind_input )

addpath('C:\Users\akselfe\Documents\GitHub\wawi');
import wawi.*


omegaGlobal = 0.0001:0.005:6;
settings.OmegaAxisGlobal = omegaGlobal;


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

phiAeroFull = phiphi;

B(:,:,1) = settings.bridge.B;
D(:,:,1) = settings.bridge.D;
loadCoeff = load(settings.bridge.loadcoeff);

adFun{1} = @(vRed)wawi.wind.adquasisteady(vRed,loadCoeff,B,D); 


Xref = settings.bridge.Xref;
TG2V = settings.bridge.TG2V;       % Define the transformation matrix Global 2 local for the Mean wind

nodes = settings.bridge.nodes;
elements = settings.bridge.elements;
TG2Le0 = settings.bridge.TG2Le0;
rho = settings.bridge.rho;

% wind profile
profile = @(x, xRef, vRef) vRef;


%%
Vref = wind_input.U; % Wind velocity
[ genCae, genKae ] = wawi.wind.compute_aero_matrices(omegaGlobal, Vref, Xref, adFun, nodes, elements, TG2Le0, TG2V, phiAeroFull, B, rho,  profile);

genMadd = zeros(size(genMs));
genCadd = -genCae;
genKadd = -genKae;


invH = wawi.pred.freq.frf(omegaGlobal, genMs, genCs, genKs, genMadd, genCadd, genKadd,false);

%% wind

z = wind_input.z;
A = [30 0 3]; % Coefficient in the one point spectra
sigma = [wind_input.sigmau 0 wind_input.sigmaw]; % Standard deviation of turbulence 
C = [0 0 0; % Decay coefficient in Davenports exponential format 
    10 0 8;
    10 0 8];



Sfun = @(w) wawi.wind.spectra.generic_Kaimal_matrix(w,z, nodes,Vref, Xref, TG2V, A , sigma, C);

genAeroSqSq = wawi.wind.windaction(omegaGlobal, Sfun, Vref, Xref, loadCoeff, nodes, elements, TG2Le0, TG2V, phiAeroFull, rho, B, D, profile);

%%

genSqSq = genAeroSqSq;


genSrSr = wawi.pred.freq.freqsim(invH, genSqSq,false);

std_lat = sqrt(trapz(omegaGlobal,squeeze(genSrSr(2,2,:))));
std_latdot = sqrt(trapz(omegaGlobal,omegaGlobal'.^2.*squeeze(genSrSr(2,2,:))));

std = std_lat;
stddot = std_latdot;

end

