clearvars
% close all
dbstop if error



dbstop if error

cd('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse\MLtrials');
% addpath('C:\Users\akselfe\OneDrive - NTNU\DERS\matlab\LongTermResponse')


TT = @(x) transform_env_x_to_u( x );
TTinv = @(u) transform_env_u_to_x( u );


%%

Uvals = 0.1:0.5:40;
sigmauvals = 0.01:0.1:7;
sigmawvals = 0.01:0.05:4;

[U,su,sw] = ndgrid(Uvals,sigmauvals,sigmawvals);

[ std,stddot ] = short_term_response( U,su,sw );

windtrain = [U(:), su(:), sw(:)]';

Data.Input = windtrain;
Data.Output = std(:)';
Data.Output2 = stddot(:)';

save('Training_data_surrogate','Data');











