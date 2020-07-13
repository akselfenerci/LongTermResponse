%% CODES Toolbox
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
% The CODES toolbox is a repository of techniques used or developed by the
% Computational Optimal Design of Engineering Systems
% (<http://codes.arizona.edu CODES>) laboratory at the University of
% Arizona. These techniques are aimed at facilitating the
% computational design optimization and reliability assessment of systems
% involving large computational simulation times and highly nonlinear
% behaviors. Through a set of high-level MATLAB functions, it is our hope
% that this toolbox will help disseminate the use of these techniques which
% are applicable to a large range of problems.
%
% <html>
% <img src="infotoolbox.png">
% </html>
%
% <html><h2>Available Documentation</h2></html>
%
% * <user_guide.html User Guide>: Installation instructions and other information.
% * <getting_started.html Getting started>: A simple example 
% highlighting some of the key features of the CODES toolbox.
% * <fit_main.html Meta-models>: Metamodel functions including SVM and
% Kriging.
% * <method.html Adaptive sampling>: Adaptive sampling techniques developed
% in the CODES laboratory (e.g., generalized max-min).
% * <sensitivity.html Sensitivity analysis>: Sensitivity analysis
% techniques for dimensionality reduction (e.g., Sobol').
% * <reliability.html Reliability assessment>: Sampling and moment-based
% approaches for reliability assessment.
% * <demo.html Demos and examples>: Examples demonstrating the
% capabilities of the toolbox.
% * <common.html Other functions and utilities>
%
%
% <html><h2>Contributors</h2>
% <table style='border:none;'><tr style='border:none'>
% <td style='border:none;padding-right:50px;'><b>Principal Investigator</b><br><br><img height=200px
% src="samy.png"><br>Samy Missoum</td>
% <td style='border:none;padding-right:50px;'><b>Lead programmer</b><br><br><img height=200px
% src="sylvain.png"><br>Sylvain Lacaze</td>
% <td style='border:none;padding-right:50px;'><b>Contributor</b><br><br><img height=200px
% src="ethan.jpg"><br>Ethan Boroson</td>
% <td style='border:none;padding-right:50px;'><b>Contributor</b><br><br><img height=200px
% src="peng.jpg"><br>Peng Jiang</td>
% </tr></table>
% </html>
%
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
