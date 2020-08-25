function [ settings ] = settings_hydro( settings )

% user settings concerning hydrodynamics


% include aerodynamic interaction
settings.hydro.button = 'on'; % motion induced
settings.hydro.button_ex = 'on'; % excitation


% locate the wadam file
settings.hydro.input_folder = 'C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\Time_dom_simulation\SimpleStudy\';
settings.hydro.wadam_folders = {'WAMIT30\'};
settings.hydro.wadam_files = 'WADAM1.LIS';

% locate where to save the output 
settings.hydro.target = 'C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\Time_dom_simulation\SimpleStudy\Hydrodynamics\HydroFitting\';
settings.hydro.target_name_matrices = 'Hydro_Matrices';
% Curve fit results
settings.hydro.target_name_fits = 'HydroFits';

% FDIopt
% keep yuwangs settings
settings.hydro.FDIopt.OrdMax     = 6;
settings.hydro.FDIopt.AinfFlag   = 0;
settings.hydro.FDIopt.Method     = 2;
settings.hydro.FDIopt.Iterations = 400;
settings.hydro.FDIopt.PlotFlag   = 0;
settings.hydro.FDIopt.LogLin     = 0;
settings.hydro.FDIopt.wsFactor   = 0.1;  
settings.hydro.FDIopt.wminFactor = 0.1;
settings.hydro.FDIopt.wmaxFactor = 10;

% state space matrix 
settings.hydro.state_space.filename = 'HydroStateSpaceMatrix.for';
settings.hydro.state_space.poly_filename = 'PolynomialOrder.mat';
settings.hydro.state_space.folder = 'C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\Time_dom_simulation\SimpleStudy\Tests_Abaqus\OnlyHydro\';

% simulation of wave excitation force
settings.hydro.sim.Nsim = settings.wind.sim.Nsim;
settings.hydro.sim.s = 13;
settings.hydro.sim.Tp = 5.9;
settings.hydro.sim.Hs = 2.4;
% settings.hydro.sim.Nw = 6000;
% settings.hydro.sim.wmax = 6;
settings.hydro.sim.omegaaxis = settings.OmegaAxisGlobal;
% settings.hydro.sim.theta = [0:15:345]/180*pi;
settings.hydro.sim.dtheta = 0.1;
% settings.hydro.sim.theta0 = pi/2;   % mean wave direction
settings.hydro.sim.theta0 = pi/4;
settings.hydro.sim.gama1 = 2.05; % wave elevation spectrum
settings.hydro.simLen = settings.wind.simLen;

% pontoon info file ( mat-file)
settings.hydro.pontooninfo.folder = 'C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\Time_dom_simulation\SimpleStudy\Hydrodynamics\HydroInputFiles\';
settings.hydro.pontooninfo.filename = 'PontoonInf.mat';
% PontoonIDs = [0 1 2 3];
% settings.hydro.pontooninfo.pontoonTypes = [PontoonIDs(1)*ones(size((1:37))) PontoonIDs(2)*ones(size((38:42))) PontoonIDs(3)*ones(size((43:45))) PontoonIDs(4)*ones(size((46)))];
settings.hydro.pontooninfo.pontoonTypes = 0;



% map
load(strcat(settings.hydro.pontooninfo.folder,settings.hydro.pontooninfo.filename)); 
settings.hydro.pontooninfo.PonAngle = pi/2; 
settings.hydro.pontooninfo.coorPon = coorPon; 
settings.hydro.pontooninfo.ponNode = ponNode; 


% hydrodynamics curve fitting
settings.hydro.PontoonIDs = [0];
settings.hydro.DOFS = [1 1;
    1 5;
    2 2;
    2 4;
    3 3;
    4 4;
    5 5;
    6 6];






