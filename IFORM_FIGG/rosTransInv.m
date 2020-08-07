function v = rosTransInv(u,wn)
%Inverse Rosenblatt transformation

v = zeros(size(u));

xiHs = 0.329771;
lambdaHs = 0.603204;
xiTz = 0.152627;
lambdaTz = 1.829504;
rho = 0.90;

v(1) = exp(xiHs*u(1)+lambdaHs); %Hs = F^{-1}_{Hs}(PHI(u_1))
v(2) = exp(xiTz*(rho*u(1)+u(2))+lambdaTz); %Tz = F^{-1}_{Tz|Hs}(PHI(u_2))

[m0, m2] = responseMoments(v(1),v(2),wn);

p = normcdf(u(3));

v(3) = sqrt(-2*m0*log(-(2*pi/10800)*sqrt(m0/m2)*log(p))); %Inverse CDF for the extreme value of the response given Hs and Tz

end