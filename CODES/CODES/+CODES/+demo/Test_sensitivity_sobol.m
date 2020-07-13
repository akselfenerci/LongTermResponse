%% <demo.html Examples> / <demo_sensitivity.html Sensitivities> / sobol
% This file is a complete demo of the capability of the |sobol| function
% from the CODES toolbox.
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Documentation
% The documentation for the |sobol| class can be found <sobol.html here>.
%
%% Set rng
% Set random number generator seed:
rng(0)

%% Simple example
% Compute sobols:

f=@(x)1/8*prod(3*x.^2+1,2);
dim=3;
n=1e5;
res=CODES.sensitivity.sobol(f,dim,n);
disp(res.S1)
disp(res.S2)
disp(res.St)

%% Convergence plot
% Compute sensitivity indices and plot the convergence with respect to
% number of samples used:

f=@(x)1/8*prod(3*x.^2+1,2);
dim=3;
n=1e5;
CODES.sensitivity.sobol(f,dim,n,'conv_seq',linspace(100,n,20));

%% Bar plot
% Compute sensitivity indices and plot them:

f=@(x)2*x(:,1)+4*x(:,2)+9*x(:,1).*x(:,2);
dim=3;
n=1e5;
CODES.sensitivity.sobol(f,dim,n,'bar_plot',true);

%% IDF
% Let us compare the sensitivities on |f| where the variables are either
% uniform between 0 and 1 (default) standard normals:

f=@(x)1/8*prod(3*x.^2+1,2);
dim=3;
n=1e5;
CODES.sensitivity.sobol(f,dim,n,'bar_plot',true);
CODES.sensitivity.sobol(f,dim,n,'bar_plot',true,'IDF',@(x)norminv(x));

%%
% Note the slider in the above figures. It is used to define a value
% (default 0) below which Sobol' indices can be disregarded. Increasing
% this value will cause the smallest indices to be removed from the bar
% plot for increased readability.
%
%% Error plot
% Compute sensitivity indices and plot them (error) using bootstraped
% confidence interval. Be mindfull that BCA (that involves Jacknife) can be
% very heavy for large samples:

f=@(x)1/8*prod(3*x.^2+1,2);
dim=3;
n=1e4;
tic;
CODES.sensitivity.sobol(f,dim,n,'err_plot',true,...
    'CI_boot',true,'boot_type','bca');
disp(['BCA ' CODES.common.time(toc)])

%%
%

tic;
CODES.sensitivity.sobol(f,dim,n,'err_plot',true,...
    'CI_boot',true,'boot_type','per');
disp(['Per ' CODES.common.time(toc)])

%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_sal"><span style="color:#005fce;">Saltelli (2002)</span>:
%   Saltelli A., (2011) <i>Making best use of model evaluations to compute
%   sensitivity indices</i>. Computer Physics Communications 145(2):280-297
%   - <a
%   href="http://dx.doi.org/10.1016/S0010-4655(02)00280-1">DOI</a></li>
% </ul></html>
%%
%%
% <html>Copyright &copy; 2015 Computational Optimal Design of Engineering Systems
% (CODES) Laboratory. University of Arizona.</html>
%%
%
% <html><table style="border: none">
%   <tr style="border: none">
%     <td style="border: none;padding-left: 0px;">
%       <a href ="http://codes.arizona.edu/"><img style="height: 50px;" src ="CODES_logo.png"></a>
%     </td><td style="border: none; vertical-align: middle;padding-left: 10px;">
%       <a href ="http://codes.arizona.edu/"><span style="font-weight:bold;font-family:Arial;font-size: 20px;color: #002147"><span style="color: #AB0520;">C</span>omputational <span style="color: #AB0520;">O</span>ptimal <span style="color: #AB0520;">D</span>esign of<br><span style="color: #AB0520;">E</span>ngineering <span style="color: #AB0520;">S</span>ystems</span></a>
%     </td><td style="border: none;padding-right: 0px;">
%       <a href = "http://www.arizona.edu/"><img style="height: 50px;" src = "AZlogo.png"></a>
%     </td>
%   </tr>
% </table></html>
