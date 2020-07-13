function [ fturb_joint ] = joint_pdf_turbulence( y, mu_dash, sigma_dash, rhoY )

% y = [y1 y2] lognormally distributed
% x = ln(y)  normally distributed with mean mu_dash and std sigma_dash

% x1 and x2 are values for sigmau and sigmaw (std of turbulence components)

% fturb_joint is the pdf value
% joint normal distribution with correlation

x = log(y);

rhoX = log(rhoY*sqrt(exp(sigma_dash(1)^2)-1)*sqrt(exp(sigma_dash(2)^2)-1)+1)/(sigma_dash(1)*sigma_dash(2));
% 
% p1 = 1/(2*pi*sigma_dash(1)*sigma_dash(2)*sqrt(1-rhoX^2));
% 
% p2 = -1/(2*(1-rhoX^2));
% 
% p3 = ((x(1)-mu_dash(1))/sigma_dash(1))^2 - 2*rhoX*((x(1)-mu_dash(1))/sigma_dash(1))*((x(2)-mu_dash(2))/sigma_dash(2)) + ((x(2)-mu_dash(2))/sigma_dash(2))^2 ; 
% 
% fturb_joint = p1*exp(p2*p3);

covX = rhoX*sigma_dash(1)*sigma_dash(2);
fturb_joint = mvnpdf(x,mu_dash,[sigma_dash(1) covX; covX sigma_dash(2)]);

end

