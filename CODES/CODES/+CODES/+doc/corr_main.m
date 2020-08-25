%% <CODES.html CODES> / <sensitivity.html sensitivity> / corr
% _Compute correlation coefficient_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |res=CODES.sensitivity.corr(X,Y)| computes selected correlation
% coefficient rho (or tau) between |X| and |Y|.
% * |res=CODES.sensitivity.corr(...,param,value)| uses a list of parameters
% |param| and values |value| (_c.f._, <#params parameter table>).
%
%% Description
% Compute standard coefficient between $\mathbf{X}$ and
% $\mathbf{Y}$. Essentially uses matlab built in |corr| but adds confidence
% interval (estimates and bootstrap) and some plotting capability.
%
% <html><a id="sampling"></a></html>
%% Sampling distribution
% Approximation of the confidence interval are obtained through
% (approximated) sampling distribution of the correlation coefficient.
%
% * Pearson, using the Fisher transform:
%
% $$\mbox{arctanh}(\widehat{\rho})\sim\mathcal{N}\left(\mbox{arctanh}(\rho),\frac{1}{n-3}\right)$$
%
% * Spearman, using the Fisher transform (only exact for $\rho=0$):
%
% $$\mbox{arctanh}(\widehat{\rho})\sim\mathcal{N}\left(\mbox{arctanh}(\rho),\frac{1.06}{n-3}\right)$$
%
% * Kendall, using normal assumption (only exact for $\tau=0$, bootstrap should be preferred here):
%
% $$\widehat{\tau}\sim\mathcal{N}\left(\tau,\frac{2(2n+5)}{9n(n-1)}\right)$$
%
% where $n$ is the number of realizations used in the estimates.
%
%% Parameters
% <html><table id="params" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'type'</span></td>
%     <td>{<span class="string">'pearson'</span>}, <span class="string">'spearman'</span>, <span class="string">'kendall'</span></td>
%     <td>Correlation coefficient type. <span class="string">'type'</span> can also be a cell array to return several coefficients at once.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'alpha'</span></td>
%     <td>positive integer, {<b>0.05</b>}</td>
%     <td>Significance level for confidence interval.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'CI'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Whether to return approximations of confidence interval, see <a href='#sampling'>Sampling distribution</a>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'CI_boot'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Whether to return bootstrapped confidence interval.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'nb_boot'</span></td>
%     <td>numeric, {200}</td>
%     <td>Number of bootstraps</td>
%   </tr>
%   <tr>
%     <td><span class="string">'boot_type'</span></td>
%     <td>{<span class="string">'bca'</span>}, <span class="string">'norm'</span>, <span class="string">'per'</span>, <span class="string">'cper'</span></td>
%     <td>Type of bootstrap confidence interval (<a href="#ref_efr">Efron, 1987</a>)</td>
%   </tr>
%   <tr>
%     <td><span class="string">'pie_plot'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Whether to provide a pie plot of the output.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'err_plot'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Whether to provide an error plot of the output.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'xlabel'</span></td>
%     <td>cell, { [ ] }</td>
%     <td>Variable labels to be used in plots.</td>
%   </tr>
% </table></html>
%
%% Example
% Compute and plot an anti-locking sample

f=@(x)1/8*prod(3*x.^2+1,2);
X=rand(100,3);Y=f(X);
res=CODES.sensitivity.corr(X,Y);
disp(res.pearson)

%% Mini Tutorial
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table id="demo_table" border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_sensitivity_corr.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_sensitivity_corr.html">A cmini tutorial of the capabilities of the <tt>corr</tt> function.</a><br></td>
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
