function [ fjoint_handle ] = joint_pdf_lognormal( sigma_dash, rhoY )

% returns function handle for the joint pdf

% use like fjoint_handle(x1,x2)

mu_dash1 = @(u) 0.122+0.039*u;
mu_dash2 = @(u) -0.657+0.03*u;

s1 = sigma_dash(1); s2 = sigma_dash(2);
p1 = @(x1,x2) 1/(2*pi*x1*x2*s1*s2*sqrt(1-rhoY^2));
p2 = @(q) exp(-q/2);

q1 = 1/(1-rhoY^2);
q2 = @(x1,x2,u) ((log(x1) - mu_dash1(u))/s1)^2;
q3 = @(x1,x2,u) 2*rhoY*((log(x1)- mu_dash1(u))/s1)*((log(x2)- mu_dash2(u))/s2);
q4 = @(x1,x2,u) ((log(x2) - mu_dash2(u))/s2)^2;

qf = @(x1,x2,u) q1*(q2(x1,x2,u)-q3(x1,x2,u)+q4(x1,x2,u));
fjoint_handle = @(x1,x2,u) p1(x1,x2)*p2(qf(x1,x2,u));


end

