%% <CODES.html CODES> / <sensitivity.html sensitivity> / dgsm
% _Compute derivative-based sensitivity measure_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |res=CODES.sensitivity.dgsm(dY)| computes sensitivity measure based on
% the |(n x dim)| matrix of partial derivatives (or gradients) at |n|
% realizations.
% * |res=CODES.sensitivity.dgsm(...,param,value)| uses a list of parameters
% |param| and values |value| (_c.f._, <#params parameter table>)
%
%% Description
% Compute derivative-based sensitivity measure of three types:
%
% * Elementary effects (EE) (<#ref_mor Morris, 1991>):
%
% $$\mu_i^0=\mathbf{E}\left[\frac{\partial f}{\partial x_i}\right]\qquad \sigma_i^0=\mathbf{V}\left[\frac{\partial f}{\partial x_i}\right]$$
%
% * DGSM1 (<#ref_cam Campolongo et al., 2007>):
%
% $$\mu_i^1=\mathbf{E}\left[\left|\frac{\partial f}{\partial x_i}\right|\right]\qquad \sigma_i^1=\mathbf{V}\left[\left|\frac{\partial f}{\partial x_i}\right|\right]$$
%
% * DGSM2 (<#ref_sob Sobol' &  Kucherenko, 2009>):
%
% $$\mu_i^0=\mathbf{E}\left[\frac{\partial f}{\partial x_i}^2\right]\qquad \sigma_i^0=\mathbf{V}\left[\frac{\partial f}{\partial x_i}^2\right]$$
%
% <html><a id="sampling"></a></html>
%% Sampling distribution
% Approximations of the confidence interval are obtained based on sampling
% distributions of sampling mean and standard deviation:
%
% * Sample mean, relatively accurate for all distributions due to CLT (<#ref_ric Rice, 2006>):
%
% $$\bar{X}\sim\mathcal{N}\left(\mu_X,\frac{\sigma_X^2}{n}\right)$$
%
% * Sample standard deviation, only accurate for normal distributions:
%
% $$(n-1)\frac{s_X^2}{\sigma_X^2}\sim\chi_{n-1}^2$$
%
% Bootstrapped CI would be more appropriate here.
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
%     <td>{<span class="string">'EE'</span>}, <span class="string">'DGSM1'</span>, <span class="string">'DGSM2'</span></td>
%     <td>Derivative-based measure type. <span class="string">'type'</span> can also be a cell array to return several measures at once.</td>
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
%     <td>Whether to return bootstraped confidence interval.</td>
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
%     <td>Whether to provide a pie plot of the output</td>
%   </tr>
%   <tr>
%     <td><span class="string">'err_plot'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Whether to provide an error plot of the output</td>
%   </tr>
%   <tr>
%     <td><span class="string">'xlabel'</span></td>
%     <td>cell, { [ ] }</td>
%     <td>Variable labels to be used in plots</td>
%   </tr>
% </table></html>
%
%% Example
% Compute and plot an anti-locking sample

f=@(x)1/8*prod(3*x.^2+1,2);
X=rand(100,3);dY=CODES.common.grad_fd(f,X);
res=CODES.sensitivity.dgsm(dY);
disp(res.EE)

%% Mini Tutorial
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table id="demo_table" border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_sensitivity_corr.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_sensitivity_corr.html">A mini tutorial of the capabilities of the <tt>corr</tt> function.</a><br></td>
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
%   <li id="ref_mor"><span style="color:#005fce;">Morris (1991)</span>:
%   Morris, M. D. (1991). <i>Factorial sampling plans for preliminary
%   computational experiments</i>. Technometrics, 33(2), 161-174.</li>
%   <li id="ref_cam"><span style="color:#005fce;">Campolongo et al.
%   (2007)</span>: Campolongo, F., Cariboni, J., & Saltelli, A. (2007).
%   <i>An effective screening design for sensitivity analysis of large
%   models</i>. Environmental Modelling & Software, 22(10), 1509-1518.</li>
%   <li id="ref_sob"><span style="color:#005fce;">Sobol' &  Kucherenko
%   (2009)</span>: Sobol', I. M., & Kucherenko, S. (2009). <i>Derivative
%   based global sensitivity measures and their links with global
%   sensitivity indices</i>. Mathematics and Computers in Simulation,
%   79(10), 3009-3017.</li>
%   <li id="ref_ric"><span style="color:#005fce;">Rice (2006)</span>: Rice,
%   J. (2006). <i>Mathematical Statistics and Data Analysis</i>. Cengage
%   Learning.</li>
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
