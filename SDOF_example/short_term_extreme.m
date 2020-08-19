function [ Fx_d ] = short_term_extreme( std,stddot,Tshort,x )

% CDF of short term extreme response for short term duration d (e.g. 10
% min, 1 hour etc.)

upcross = (stddot./(2*pi.*std));

Fx_d = exp(-upcross.*Tshort.*exp(-x.^2./(2.*std.^2)));



end

