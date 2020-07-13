%% <CODES.html CODES Toolbox> / <user_guide.html User Guide> / Installation
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Download
% Starting with MATLAB 2014b a new toolbox packaging tool was added. If you
% are using MATLAB 2014b or newer, download the
% <http://codes.arizona.edu/toolbox/CODES.mltbx mltbx file> and open it in
% MATLAB.
%
% If you are using MATLAB 2014a or earlier, download the
% <http://codes.arizona.edu/toolbox/CODES.zip zip file>, extract the
% _CODES_ folder in the location of your choice, and add the _CODES_ folder
% to your MATLAB path. *IMPORTANT: only add the _CODES_ folder to the path,
% not the folder and sub folders*.
%
%% Installation
% For the construction SVM, the CODES toolbox either uses its own SVM function or it uses the
% <http://www.csie.ntu.edu.tw/~cjlin/libsvm/ LIBSVM> library. In order to
% use the CODES toolbox to its fullest extent, run the command:
%
%  CODES.install
%
% This file will mex all <http://www.csie.ntu.edu.tw/~cjlin/libsvm/ LIBSVM>
% Matlab compatibility files (requires a properly installed Matlab supported
% C++ compiler, see <http://www.mathworks.com/support/compilers/ Supported
% Compilers>). In addition, it builds a searchable database for the help
% and starts the classic help browser for the first use.
%
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
