%% <CODES.html CODES> / <sensitivity.html sensitivity> / sobol
% _Compute (Sobol) global sensitivity indices_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |res=CODES.sensitivity.sobol(f,dim,n)| computes first order,
% second order and total global sensitivity indices |S|, |Sij| and |St|
% respectively of a function |f|. The problem dimensions |dim| and sample
% size |n| must be provided.
% * |[...]=CODES.sensitivity.sobol(...,param,value)| uses a list of
% parameters |param| and values |values| (_c.f._, <#params parameter
% table>).
%
%% Description
% Compute two sets of (Sobol) global sensitivity indices defined as:
%
% * First order
%
% $$S_i=\frac{\mbox{V}[\mbox{E}(f|x_i)]}{\mbox{V}[f]}$$
%
% * Second order
%
% $$S_{ij}=\frac{\mbox{V}[\mbox{E}(f|x_i,x_j)]-\mbox{V}[\mbox{E}(f|x_i)]-\mbox{V}[\mbox{E}(f|x_j)]}{\mbox{V}[f]}$$
%
% * Total
%
% $$S_{i}^T=\frac{\mbox{E}[\mbox{V}(f|x_{-i})]}{\mbox{V}[f]}$$
%
% and computed as described in <#ref_sal Saltelli (2002)>. This procedure
% calls the function $n(2dim+2)$ times.
%
% The function returns |S|, |Sij| and |St| such that (for $dim=m$):
%
% $$S_i=\left[\begin{array}{ccc}S_1&\cdots&S_{m}\\S_1^\prime&\cdots&S_{m}^\prime\end{array}\right]$$
%
% $$S_{ij}=\left[\begin{array}{cccc}NaN&S_{12}&\cdots&S_{1m}\\S_{12}^\prime&NaN&&\vdots\\\vdots&&\ddots&S_{(m-1)m}\\S_{1m}^\prime&\cdots&S_{(m-1)m}^\prime&NaN\end{array}\right]$$
%
% $$S^T=\left[\begin{array}{ccc}S_1^T&\cdots&S_{m}^T\\S_1^{T\prime}&\cdots&S_{m}^{T\prime}\end{array}\right]$$
%
% where the $S_\star^\prime$ notation refers to the second set of
% estimates.
%
% <html>If neither bounds (<span class='string'>'lb'</span> and <span
% class='string'>'ub'</span>) or marginal inverse distribution functions
% (<span class='string'>'IDF'</span>) are specified, variables are assumed
% to be uniform between 0 and 1.</html>
%
%% Parameters
% <html><table id="params" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'lb'</span></td>
%     <td>positive integer array, {<b>0</b>}</td>
%     <td>Lower bounds for uniform variables</td>
%   </tr>
%   <tr>
%     <td><span class="string">'ub'</span></td>
%     <td>positive integer array, {<b>1</b>}</td>
%     <td>Upper bounds for uniform variables</td>
%   </tr>
%   <tr>
%     <td><span class="string">'IDF'</span></td>
%     <td><tt>function_handle</tt></td>
%     <td>Marginal inverse distribution functions in case of non uniform random variables</td>
%   </tr>
%   <tr>
%     <td><span class="string">'sampler'</span></td>
%     <td>{<span class="string">'rand'</span>}, <span class="string">'halton'</span>, <span class="string">'sobol'</span>, <span class="string">'lhs'</span>, <span class="string">'cvt'</span></td>
%     <td>Sets the sampler to get the two DOE used in the approach.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'vectorized'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Whether the function is vectorized</td>
%   </tr>
%   <tr>
%     <td><span class="string">'f_parallel'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>If not vectorized, whether the function should be evaluated in parallel</td>
%   </tr>
%   <tr>
%     <td><span class="string">'conv_seq'</span></td>
%     <td>positive integer array, { [ ] }</td>
%     <td>If provided, trigger a convergence plot. For every value of <span class="string">'conv_seq'</span>, the indices are recomputed. For example, if |n=1000| and <span class="string">'conv_seq'</span>|=[10,100,1000]|, all indices will be computed using 10, 100 and 1000 samples.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'conv_leg'</span></td>
%     <td>logical, {<tt>true</tt>}</td>
%     <td>Whether convergence plot should have a legend or not</td>
%   </tr>
%   <tr>
%     <td><span class="string">'bar_plot'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Whether a bar plot of the indices should be provided</td>
%   </tr>
%   <tr>
%     <td><span class="string">'bar_leg'</span></td>
%     <td>logical, {<tt>true</tt>}</td>
%     <td>Whether bar plot should have a legend or not</td>
%   </tr>
%   <tr>
%     <td><span class="string">'CI_boot'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Whether to return bootstraped confidence interval</td>
%   </tr>
%   <tr>
%     <td><span class="string">'nb_boot'</span></td>
%     <td>numeric, {200}</td>
%     <td>Number of bootstraps</td>
%   </tr>
%   <tr>
%     <td><span class="string">'alpha'</span></td>
%     <td>positive integer, {<b>0.05</b>}</td>
%     <td>Significance level for confidence interval.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'boot_type'</span></td>
%     <td>{<span class="string">'bca'</span>}, <span class="string">'norm'</span>, <span class="string">'per'</span>, <span class="string">'cper'</span></td>
%     <td>Type of bootstrap confidence interval (<a href="#ref_efr">Efron, 1987</a>).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'err_plot'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Whether an error plot of the indices should be provided.</td>
%   </tr>
% </table></html>
%
% <html>In addition, options from
% <a href="http://www.mathworks.com/help/gads/multistart-class.html"><tt>MultiStart</tt></a>
% can be used as well, when <span class="string">'MultiStart'</span> is set to <span class="string">'MATLAB'</span>.</html>
%
%% Example
% Compute and plot an anti-locking sample

f=@(x)1/8*prod(3*x.^2+1,2);
dim=3;
n=1e3;
res=CODES.sensitivity.sobol(f,dim,n);
disp(res)

%% Mini Tutorial
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table id="demo_table" border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_sensitivity_sobol.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_sensitivity_sobol.html">A mini tutorial of the capabilities of the <tt>sobol</tt> function.</a><br></td>
%         </tr>
%     </table>
% </html>
%
%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_efr">
%   <span style="color:#005fce;">Efron (1987)</span>: Efron, B. (1987).
%   <i>Better bootstrap confidence intervals</i>. Journal of the American
%   Statistical Association, 82(397), 171-185. <a
%   href="https://dx.doi.org/10.2307%2F2289144">DOI</a>
%   </li>
%   <li id="ref_sal"><span style="color:#005fce;">Saltelli (2002)</span>:
%   Saltelli A., (2011) <i>Making best use of model evaluations to compute
%   sensitivity indices</i>. Computer Physics Communications 145(2):280-297
%   - <a
%   href="http://dx.doi.org/10.1016/S0010-4655(02)00280-1">DOI</a></li>
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
