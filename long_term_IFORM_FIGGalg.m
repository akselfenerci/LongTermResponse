clearvars;
close all;

dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse');

RSM = load('RSmodel');


TT = @(x) transform_variables_x_to_u( x,RSM );

TTinv = @(u) transform_variables_u_to_x( u,RSM );

%%


p = 1/(100*365*24*6);
beta = -norminv(p);
h = 0.001;

maxIt = 30;

R_e = @(u) cellfun(@(y) y(end),{TTinv(u)});


u = zeros(4,maxIt+1);

u(:,1) = [0; 0; 0; beta];

g7new = R_e(u(:,1));

nShortTermCalc = 1;
nBacktrackTot = 0;

for i=1:maxIt
    %g1 = R_e(u(:,i)+[-h;0;0]);
    g2 = R_e(u(:,i)+[h;0;0;0]);
    %g3 = R_e(u(:,i)+[0;-h;0]);
    g4 = R_e(u(:,i)+[0;h;0;0]);
    %g5 = R_e(u(:,i)+[0;0;-h]);
    g6 = R_e(u(:,i)+[0;0;h;0]);
    
    g8 = R_e(u(:,i)+[0;0;0;h]);
    
    g7 = g7new;

    grad = [g2-g7; g4-g7; g6-g7; g8-g7]/h;
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

designPoint = TTinv(u(:,i+1));


