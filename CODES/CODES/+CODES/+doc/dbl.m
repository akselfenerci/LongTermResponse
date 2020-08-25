%% <CODES.html CODES> / <rbdo.html rbdo> / dbl
% _Double loop RBDO using RIA or PMA_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |res=CODES.rbdo.dbl(obj,g,Pf_T,z_start,theta_start,dim)| solve the RBDO
% problem for the objective function |obj|, set of constraints |g|, target
% probabilities |Pf_T|, starting at |z_start| and |theta_start| (both can
% be defined to [] if no deterministic of hyper-parameter design variables
% respectively). |dim| specifies the number of random variables.
% * |res=CODES.rbdo.dbl(...,param,value)| uses a list of
% parameters |param| and values |value| (see, <#params parameter table>).
%
%% Description
% Solves the RBDO problem defined as:
%
%% Parameters
% <html><table id="params" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'ra'</span></td>
%     <td><span class="string">'RIA'</span>, {<span class="string">'PMA'</span>}</td>
%     <td>The realiability technique to use, RIA or PMA.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'T'</span></td>
%     <td><tt>function_handle</tt></td>
%     <td>Transformation function.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'Tinv'</span></td>
%     <td><tt>function_handle</tt></td>
%     <td>Inverse transformation function.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'z_lb'</span>, <span class="string">'z_ub'</span>, <span class="string">'theta_lb'</span>, <span class="string">'theta_ub'</span></td>
%     <td>real floats</td>
%     <td>Lower and upper bounds on z and theta.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'MultiStart'</span></td>
%     <td>{<span class="string">'CODES'</span>}, <span class="string">'MATLAB'</span></td>
%     <td>Defines whether MATLAB or CODES multistart fmincon should be used.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'Display'</span></td>
%     <td>{<span class="string">'off'</span>}, <span class="string">'iter'</span>, <span class="string">'final'</span></td>
%     <td>Defines the verbose level.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'sign'</span></td>
%     <td>{<span class="string">'both'</span>}, <span class="string">'plus'</span>, <span class="string">'minus'</span></td>
%     <td>Search generalized "max-min" using all samples, only +1 samples or -1 samples</td>
%   </tr>
% </table></html>
%
% <html>In addition, options from
% <a href="http://www.mathworks.com/help/gads/multistart-class.html"><tt>MultiStart</tt></a>
% can be used as well, when <span class="string">'MultiStart'</span> is set to <span class="string">'MATLAB'</span>.</html>
%
%% Example
% Compute and plot a generalized "max-min" sample

DOE=CODES.sampling.cvt(20,2,'lb',[-5 -5],'ub',[5 5]);
svm=CODES.fit.svm(DOE,DOE(:,1)-DOE(:,2));
x_gmm=CODES.sampling.gmm(svm,@(x)sum(log(normpdf(x)),2),@(N)normrnd(0,1,N,2));
figure('Position',[200 200 500 500])
svm.isoplot('lb',[-5 -5],'ub',[5 5])
plot(x_gmm(1),x_gmm(2),'ms')

%% Mini Tutorial
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_method_gmm.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_method_gmm.html">A mini tutorial of the capabilities of the <tt>gmm</tt> function.</a><br></td>
%         </tr>
%     </table>
% </html>
%
%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_lac"><span style="color:#005fce;">Lacaze and Missoum,
%   (2014)</span>: Lacaze S., Missoum S., (2014) <i>A generalized "max-min"
%   sample for surrogate update</i>. Structural and Multidisciplinary
%   Optimization 49(4):683-687 - <a href="http://dx.doi.org/10.1007/s00158-013-1011-9">DOI</a></li>
% </ul></html>
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
