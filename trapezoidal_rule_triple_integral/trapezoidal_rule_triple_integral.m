function  out = trapezoidal_rule_triple_integral(x, y, z, mat)
%  
% Calculates a triple integral using the trapezoidal rule.
% 
%
% By: Mohammed S. Al-Rawi
% IEETA, University of Aveiro
% Portugal
% March, 7, 2013 
%
% Please send feedback if you have any issue with this function to
%  rawi707@yahoo.com
%
% -- mat is a 3D matrix that contains the function values, e.g. f(x,y,z),
% size of f is [M N K]
% -- x --y --zz are the vectors to be used with the function to generate mat
%     size of x is M, size of y is N, and size of z is K
%
% This function makes use of the function
% trapezoidal_rule_double_integral.m that can be found at:
% http://www.mathworks.com/matlabcentral/fileexchange/40631-2d-trapezoidal-rule
%
% Example:
% x=0:.05:pi;
% y=0:.05:1;
% z=-1:.05:1;
% [xx,yy,zz] = ndgrid(x,y,z); 
% mat = yy.*sin(xx)+zz.*cos(xx);

% out = trapezoidal_rule_triple_integral(x, y, z, mat)
% out =
% 
%     1.9987
% 
%  Now, using Matlab's triple integration function
% F = @(x,y,z)y*sin(x)+z*cos(x);
% Q = triplequad(F,0,pi,0,1,-1,1)
% 
% Q =
% 
%     2.0000
%

%   The below does work, but, let's check the latest line
%  
% K=length(z);
% 
% tmp=zeros(K,1);
% for i=1:K
%     tmp_mat=mat(:,:,i);
%     tmp(i)= trapezoidal_rule_double_integral(x, y, tmp_mat); % 2D integral
% end
% 
% out =trapz(z,tmp); % then, a 1D integral

out = trapz(x,trapz(y,trapz(z,mat,3),2),1);

% Amazingly, it does work




