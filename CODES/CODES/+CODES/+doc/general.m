%% <CODES.html CODES Toolbox> / <user_guide.html User Guide> / General Information
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Package folder
% The CODES toolbox is an object oriented toolbox that was built using the MATLAB
% package feature. A complete description of the MATLAB package feature can be
% found at:
%
% * <http://www.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html
% Packages Create Namespaces>
% * <http://www.mathworks.com/help/matlab/matlab_oop/importing-classes.html
% Importing Classes>
%
% In short, all classes and functions from this toolbox are stored
% into their respective namespaces.
%
%% Namespaces
% There are four primary namespaces in the CODES toolbox:
%
% * <common.html +common> gathers a set of common or basic routines. They do
% not present any scientific information but allow for a much greater ease of
% use. 
% * <demo.html +demo> gathers a set of demonstrations and examples of the
% different elements of the CODES toolbox. These demonstrations provide
% starting material spanning all possible parameters of the elements of the CODES
% toolbox.
% * <fit_main.html +fit> gathers the meta-models that can be used with the
% CODES toolbox.
% * <method.html +method> gathers a set of methods that represent the
% scientific contribution of this toolbox.
%
%% Import namespaces
% In order to avoid any form of conflict in name resolution, all CODES
% toolbox element are accessed through their namespace. For example, to
% train an SVM one uses
%
% <html><pre>CODES.fit.svm</pre></html>
%
% However, if one is assured that there will not be any conflict,
% namespaces can be imported. Therefore, equivallentally to above:
%
% <html><pre>import <span class="string">CODES.fit.*</span><br>svm</pre></html>
%
% will import the content from |CODES.fit| so that |svm| can be accessed
% immediately. To clear the imported namespace, use:
%
% <html><pre>clear <span class="string">import</span></pre></html>
%
%% Conventions
% A sample of |n| realization of random vector of size |dim| should be a
% matrix of size |(n x dim)|. For example, 10 realizations of a standard
% bivariate gaussian would be:

x=normrnd(0,1,10,2);
disp(x)

%%
% Some functions in this toolbox allow to pass gradient of a function |f|.
% When that happens, for a |(n x dim)| sample, |f(x)| is expected to return
% 2 output, |y| the |(n x 1)| function value array and |dy|, the |(n x
% dim)| gradient array. For example:

f=@(x)deal(2*x(:,1)+3*x(:,2).^3,[2*ones(size(x,1),1) 3*3*x(:,2).^2]);
[y,dy]=f([0 0;1 2;3 0.25]) %#ok<NOPTS>

%% Toolbox help
% To open the help, use the command:
%
%  CODES.doc
%
% Depending on the MATLAB version used, the CODES toolbox will appear in
% different ways:
%
% <html>
% <b>MATLAB 2012a or older:</b><br>
% <img src="old_help.png" width=400px style="margin-top:5px"><br><br>
% <b>MATLAB 2012b to MATLAB 2014b:</b><br>
% <img src="new_help.png" width=400px style="margin-top:5px"><br><br>
% <b>MATLAB 2015a and newer:</b><br>
% <img src="help_2015.png" width=400px style="margin-top:5px"><br><br>
% </html>
%
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
