function [ Fx_d ] = short_term( U,sigmau,sigmaw,x )

wind_input.z = 60;
wind_input.U = U;
wind_input.sigmau = sigmau;
wind_input.sigmaw = sigmaw;

settingsMAT = load('settings.mat');

[ std,stddot ] = short_term_response( settingsMAT.settings,wind_input );

Tshort = 600;

[ Fx_d ] = short_term_extreme( std,stddot,Tshort,x );


end

