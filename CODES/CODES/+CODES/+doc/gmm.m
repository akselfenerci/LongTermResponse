%% <CODES.html CODES> / <method.html sampling> / gmm
% _Find a generalized "max-min" sample_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |x_gmm=CODES.sampling.gmm(M,logjpdf,rng)| finds a generalized "max-min"
% sample |x_gmm| such that |M.eval(x)=0|, for the log joint probability
% density function |logjpdf|. |rng| is a sampler or a set of points
% used to determine starting points for the optimization.
% * |x_gmm=CODES.sampling.gmm(...,param,value)| uses a list of
% parameters |param| and values |value| (see, <#params parameter table>).
%
%% Description
% This function finds a generalized "max-min" sample as introduced in
% <#ref_lac Lacaze and Missoum (2014)>:
%
% $$\begin{array}{rl}x_{mm}=\mathop{\arg\max}\limits_{x}&\mathbf{f}_X(x)^{\frac{1}{d}}\mathop{\min}\limits_{i}\left|\left|x-x^{(i)}\right|\right|\\\textbf{s.t.} & s(x)=0\\&l_j\leq x_j\leq u_j\end{array}$$
%
% where $x^{(.)}$ are the existing samples used to train $s$, a meta-model
% (an SVM in Lacaze's work) and $\mathbf{f}_X$ is the probability density
% function of $X$. The numerical implementation of this optimization
% problem follows the steps highlighted in <#ref_lac Lacaze and Missoum
% (2014)> regarding the use of the Chebychev distance (infinite norm). This
% problem being made differentiable, it is then solved using multi-start
% SQP.
%
% Note that the joint PDF $\mathbf{f}_{\mathbf{X}}$ can be as general as
% desired including a mix of marginals, dependence structures and copulas.
%
%% Parameters
% <html><table id="params" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'dlogjpdf'</span></td>
%     <td><tt>function_handle</tt>, { [ ] }</td>
%     <td>Gradient of the log of the joint pdf. Must return an <tt>(M.dim x n_t)</tt> matrix where <tt>n_t</tt> is the number of samples passed to the function.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'nb'</span></td>
%     <td>positive integer, {1}</td>
%     <td>Number of "max-min" samples requested ( <span class="string">'nb'</span> &ge; 2 is refered to as parallel, see <a href="#ref_lac">Lacaze and Missoum (2014)</a>)</td>
%   </tr>
%   <tr>
%     <td><span class="string">'intensity'</span></td>
%     <td>positive integer, {30}</td>
%     <td>Number of starting points for the multi-start SQP algorithm</td>
%   </tr>
%   <tr>
%     <td><span class="string">'UseParallel'</span></td>
%     <td>logical, {<tt>M.UseParallel</tt>}</td>
%     <td>Should parallel set up be used</td>
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
%% See also
% <anti_lock.html anti_lock> | <edsd.html edsd> | <mm.html mm>
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
