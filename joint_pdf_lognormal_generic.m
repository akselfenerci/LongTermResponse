function [ fjoint_handle ] = joint_pdf_lognormal_generic(mu_dash, sigma_dash, rhoY )

% returns function handle for the joint pdf

% use like fjoint_handle(x1,x2)

mu_dash1 = mu_dash(1);
mu_dash2 = mu_dash(2);

s1 = sigma_dash(1); s2 = sigma_dash(2);
p1 = @(x1,x2) 1/(2*pi*x1*x2*s1*s2*sqrt(1-rhoY^2));
p2 = @(q) exp(-q/2);

q1 = 1/(1-rhoY^2);
q2 = @(x1,x2) ((log(x1) - mu_dash1)/s1)^2;
q3 = @(x1,x2) 2*rhoY*((log(x1)- mu_dash1)/s1)*((log(x2)- mu_dash2)/s2);
q4 = @(x1,x2) ((log(x2) - mu_dash2)/s2)^2;

qf = @(x1,x2) q1*(q2(x1,x2)-q3(x1,x2)+q4(x1,x2));
fjoint_handle = @(x1,x2) p1(x1,x2)*p2(qf(x1,x2));


end

