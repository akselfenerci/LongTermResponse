clearvars
close all
clc

dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\SDOF_example');



TT = @(x) transform_x_to_u( x );

% xx = [25 6 3 0.5];
% u = TT(xx);


%%

options = optimoptions(@fmincon,...
    'Display','iter-detailed','Algorithm','sqp','PlotFcns','optimplotfval');

obj_fun = @(x) norm(TT(x)); 

x0 = [18 2 1 0.1];

problem = createOptimProblem('fmincon','x0',x0,...
    'objective',obj_fun,...
    'Aeq',[0 0 0 1],...
    'beq',0.736,...
    'options',options);
gs = GlobalSearch;
xopt = run(gs,problem);


% [xopt,fval] = fmincon(obj_fun,x0,...
%     [],[],[],[],[20 0 0 0],[28 4 2 1],@limit_state_form,options);

Flong = normcdf(norm(TT(xopt)));



Tratio = (365*24*6*100);
F_char = Flong^Tratio;

Ftarget = 1-1/(365*24*6*100);
F_char_target = Ftarget^Tratio;

err = 100*abs(F_char - F_char_target)/F_char_target;





%% try plotting

% Uvals = 0.1:0.1:40;
% sigmauvals = 0.1:0.1:10;
% sigmaw = 1;
% 
% [X,Y] = meshgrid(Uvals,sigmauvals);
% Z = sigmaw*ones(size(X));
% X4 = 0.736*ones(size(X));
% 
% obj_fun = arrayfun(@(x,y,z,t) norm(TT([x y z t])), X,Y,Z,X4,'UniformOutput',0);
% 
% figure; 
% surf(X,Y,cell2mat(obj_fun))





