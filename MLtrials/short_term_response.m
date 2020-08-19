function [ std,stddot ] = short_term_response( U,su,sw )

m = 22740;
fn = 0.1;
w = 0.1*2*pi;
k = w^2*m;
ksi = 0.03;

fp = 0.15;

% mechanical admittance at the spectral peak
hh2 = 1./((1-(fp./fn).^2)^2+4*ksi.^2*(fp./fn).^2);

% wind force
rho = 1.225;
D = 3;
B = 30;
Cd = 1;
Cl = 0.1;

A1 = rho.^2*U.^2*D.^2*Cd.^2;
A2 = rho.^2*U.^2*B.^2*Cl.^2/4;

varF = A1.*su.^2+A2.*sw.^2;

std = sqrt(hh2.*varF./k.^2);
stddot = 2*pi*fp.*std;

end


