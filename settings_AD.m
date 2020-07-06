function [ settings ] = settings_AD( settings )

% user settings concerning Aerodynamic Derivatives

% include aerodynamic interaction
settings.AD.button = 'on';

% input folder path
input_folder = cd;
% AD file name 
AD_filename = 'ADsHDPoints';

settings.AD.ADfile = strcat(input_folder,'\',AD_filename);

% target folder to save outputs
settings.AD.target = cd;
mkdir(settings.AD.target);
settings.AD.target_name = 'AeroStateSpaceMatrix';
settings.AD.target_name_AD = 'Fitted_ADs';

% reduced velocity range
settings.AD.redv = linspace(0,20,200);

% for plotting
settings.AD.plot.posAD = [1 5 2   11 7 8  17 13 14;   4 6 3    12 10 9   18 16 15];
settings.AD.plot.label = {'P_1^*' 'P_2^*' 'P_3^*' 'P_4^*' 'P_5^*' 'P_6^*' 'H_1^*' 'H_2^*' 'H_3^*' 'H_4^*' 'H_5^*' 'H_6^*' 'A_1^*' 'A_2^*' 'A_3^*' 'A_4^*' 'A_5^*' 'A_6^*'};


end

