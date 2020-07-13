%% <demo.html Examples> / <demo_sensitivity.html Sensitivities> / dgsm
% This file is a complete demo of the capability of the |dgsm| function
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
% The documentation for the |dgsm| class can be found <dgsm.html here>.
%
%% Set rng
% Set random number generator seed:
rng(0)

%% Simple example
% Compute derivative-based measures using all three kind:

f=@(x)1/8*prod(3*x.^2+1,2);
X=rand(100,3);dY=CODES.common.grad_fd(f,X);
res=CODES.sensitivity.dgsm(dY,'type',{'EE','DGSM1','DGSM2'});
disp(res.EE.mu)
disp(res.DGSM1.mu)
disp(res.DGSM2.mu)

%% Pie plot
% Compute sensitivity indices and plot them (pie):

f=@(x)1/8*prod(3*x.^2+1,2);
X=rand(100,3);dY=CODES.common.grad_fd(f,X);
CODES.sensitivity.dgsm(dY,'pie_plot',true);

%% Error plot
% Compute sensitivity indices and plot them (error) using approximated and
% bootstraped confidence interval:

f=@(x)1/8*prod(3*x.^2+1,2);
X=rand(100,3);dY=CODES.common.grad_fd(f,X);
CODES.sensitivity.dgsm(dY,'err_plot',true,'CI_boot',true,'CI',true);

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
