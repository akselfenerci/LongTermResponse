function [ std,stddot ] = short_term_response( U,su,sw )

m = 22740;
fn = 0.1;
w = 0.1*2*pi;
k = w^2*m;
ksi = 0.03;

% wind force
rho = 1.225;
D = 3;
B = 30;
Cd = 1;
Cl = 0.1;

A1 = rho.^2*U.^2*D.^2*Cd.^2;
A2 = rho.^2*U.^2*B.^2*Cl.^2/4;

% wind spectra
z = 60;
Au = 30; Aw = 3;
fz = fn*z./U;
Suu = su.^2.*Au.*fz./(fn.*(1+1.5.*Au.*fz).^(5/3));
Sww = sw.^2.*Aw.*fz./(fn.*(1+1.5.*Aw.*fz).^(5/3));


varX = (2/k^2)*(A1.*Suu+ A2.*Sww)*pi*fn/4/ksi;

std = sqrt(varX);
stddot = 2*pi*fn.*std;

end


