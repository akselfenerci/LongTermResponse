clear all;
close all;

addpath(genpath('..\Functions'));
addpath('Functions');

%wn = 0.5;
%wn = 1.0;
%wn = 2.0;
wn = Inf;

%%%%%%%%%%%%%%%%%%%%%%%IFORM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%p = 1/(8*365*10000);
p = 1/(8*365*100);
beta = -norminv(p);
h = 0.001;

maxIt = 30;

R_e = @(u) [0 0 1]*rosTransInv(u,wn); %The limit state function

u = zeros(3,maxIt+1);

u(:,1) = [0; 0; beta];
g7new = R_e(u(:,1));
nShortTermCalc = 1;
nBacktrackTot = 0;

for i=1:maxIt
    %g1 = R_e(u(:,i)+[-h;0;0]);
    g2 = R_e(u(:,i)+[h;0;0]);
    %g3 = R_e(u(:,i)+[0;-h;0]);
    g4 = R_e(u(:,i)+[0;h;0]);
    %g5 = R_e(u(:,i)+[0;0;-h]);
    g6 = R_e(u(:,i)+[0;0;h]);
    g7 = g7new;

    grad = [g2-g7; g4-g7; g6-g7]/h;
    gradNorm = norm(grad);
    
    u(:,i+1) = beta*grad/gradNorm;
    g7new = R_e(u(:,i+1));    
    nShortTermCalc = nShortTermCalc + 4;
    
    updateAngle = acos((grad.'*u(:,i))/(beta*gradNorm));
    dirDerBeta = sqrt((beta*gradNorm)^2-(grad.'*u(:,i))^2);
    
    %Backtracking performed to ensure convergence
    nBacktrack = 0;
    while (g7new-g7 < (1e-4/(2^nBacktrack))*dirDerBeta*updateAngle) %&& nBacktrack < 10
        u(:,i+1) = beta*(u(:,i)+u(:,i+1))/norm(u(:,i)+u(:,i+1));
        g7new = R_e(u(:,i+1));
        nShortTermCalc = nShortTermCalc + 1;
        
        nBacktrack = nBacktrack + 1;
    end
    
    nBacktrackTot = nBacktrackTot + nBacktrack;
    
    if norm(u(:,i+1)-u(:,i))/norm(u(:,i+1)) <= 1e-3
        disp('Convergence of IFORM')
        break;
    end
end

designPoint = rosTransInv(u(:,i+1),wn);

HsDesignPoint = designPoint(1)
TzDesignPoint = designPoint(2)
response100yrReturnVal = designPoint(3)

%%%%%%%%%%%%%%%%%%%%%%%ENDING IFORM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
