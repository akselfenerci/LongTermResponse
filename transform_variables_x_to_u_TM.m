function [ u ] = transform_variables_x_to_u_TM( xx,RSM )

% variables are U, sigmau, sigmaw and Xd


% rosenblatt transform

% U, mean speed
u1 = norminv(logncdf(xx(1),1.0967,0.4894));

% sigma u, turbulence
rhoY = 0.8148;
sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;

mu_dash(1) = 0.122+0.039*xx(1);
mu_dash(2) = -0.657+0.03*xx(1);

Cxx(1,1) = sigma_dash(1)^2;
Cxx(2,2) = sigma_dash(2)^2;
Cxx(1,2) = rhoY*sigma_dash(1)*sigma_dash(2);
Cxx(2,1) = Cxx(1,2);

[S,D] = eig(Cxx);
AA = D'*S';

uturb = AA*(log([xx(2) xx(3)]) - mu_dash)';

u2 = uturb(1);
u3 = uturb(2);

% Xd, short-term extreme response
Tshort = 600;
[std] = predict(RSM.lmSTD,xx(1:3));
[stddot] = predict(RSM.lmSTDdot,xx(1:3));
std(std<0) = 1e-5;
stddot(stddot<0) = 1e-5;
[ Fx_d ] = short_term_extreme( std,stddot,Tshort,xx(4) );
u4 = norminv(Fx_d);


u = [u1 u2 u3 u4];

end

