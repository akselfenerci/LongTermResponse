function [ x ] = short_term_extreme_inv( std,stddot,Tshort,Fx )

% inverse CDF of short term extreme response for short term duration d (e.g. 10
% min, 1 hour etc.)

upcross = (stddot./(2*pi*std));

x = sqrt(-log(-log(Fx)./upcross./Tshort).*2.*std.^2);

end

