%% <CODES.html CODES> / <method.html sampling> / mm
% _Find a "max-min" sample_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |x_mm=CODES.sampling.mm(M,lb,ub)| finds a "max-min" sample |x_mm| such
% that |M.eval(x)=0| and |lb < x < ub|.
% * |x_mm=CODES.sampling.mm(...,param,value)| uses a list of parameters
% |param| and values |value| (_c.f._, <#params parameter table>).
%
%% Description
% This function finds a "max-min" sample as introduced in <#ref_bas
% Basudhar and Missoum (2010)>:
%
% $$\begin{array}{rl}x_{mm}=\mathop{\arg\max}\limits_{x}&\mathop{\min}\limits_{i}\left|\left|x-x^{(i)}\right|\right|\\\textbf{s.t.} & s(x)=0\\&l_j\leq x_j\leq u_j\end{array}$$
%
% where $x^{(.)}$ are the existing samples used to train $s$, a meta-model
% (an SVM in Basudhar's work). The numerical implementation of this
% optimization problem follows the steps highlighted in <#ref_lac Lacaze
% and Missoum (2014)> regarding the use of the Chebychev distance (infinite
% norm). This problem being made differentiable, it is then solved using
% multi-start SQP. 
%
%% Parameters
% <html><table id="params" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'nb'</span></td>
%     <td>positive integer, {1}</td>
%     <td>Number of "max-min" samples requested ( <span class="string">'nb'</span> &ge; 2 is refered to as parallel, see <a href="#ref_lin">Lin et al. (2012)</a>)</td>
%   </tr>
%   <tr>
%     <td><span class="string">'intensity'</span></td>
%     <td>positive integer, {30}</td>
%     <td>Number of starting points for the multi-start SQP algorithm</td>
%   </tr>
%   <tr>
%     <td><span class="string">'UseParallel'</span></td>
%     <td>logical, {<tt>M.UseParallel</tt>}</td>
%     <td>Should parallel setup be used</td>
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
% </table></html>
%
% <html>In addition, options from
% <a href="http://www.mathworks.com/help/gads/multistart-class.html"><tt>MultiStart</tt></a>
% can be used as well, when <span class="string">'MultiStart'</span> is set to <span class="string">'MATLAB'</span>.</html>
%
%% Example
% Compute and plot a "max-min" sample

DOE=CODES.sampling.cvt(20,2,'lb',[-5 -5],'ub',[5 5]);
svm=CODES.fit.svm(DOE,DOE(:,1)-DOE(:,2));
x_mm=CODES.sampling.mm(svm,[-5 -5],[5 5]);
figure('Position',[200 200 500 500])
svm.isoplot('lb',[-5 -5],'ub',[5 5])
plot(x_mm(1),x_mm(2),'ms')

%% Mini Tutorial
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_method_mm.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_method_mm.html">A mini tutorial of the capabilities of the <tt>mm</tt> function.</a><br></td>
%         </tr>
%     </table>
% </html>
%
%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_bas"><span style="color:#005fce;">Basudhar and Missoum (2010)</span>: Basudhar A., Missoum S., (2010) <i>An improved adaptive
%   sampling scheme for the construction of explicit boundaries</i>. Structural
%   and Multidisciplinary Optimization 42(4):517-529 - <a href="http://dx.doi.org/10.1007/s00158-010-0511-0">DOI</a></li>
%   <li id="ref_lin"><span style="color:#005fce;">Lin et al.
%   (2012)</span>: Lin S., Basudhar A., Missoum S., (2012) <i>Parallel
%   construction of explicit boundaries using support vector machines</i>.
%   Engineering Computations 30(1):132-148 - <a href="http://dx.doi.org/10.1108/02644401311286099">DOI</a></li>
%   <li id="ref_lac"><span style="color:#005fce;">Lacaze and Missoum,
%   (2014)</span>: Lacaze S., Missoum S., (2014) <i>A generalized "max-min"
%   sample for surrogate update</i>. Structural and Multidisciplinary
%   Optimization 49(4):683-687 - <a href="http://dx.doi.org/10.1007/s00158-013-1011-9">DOI</a></li>
% </ul></html>
%
%% See also
% <anti_lock.html anti_lock> | <edsd.html edsd> | <gmm.html gmm>
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
