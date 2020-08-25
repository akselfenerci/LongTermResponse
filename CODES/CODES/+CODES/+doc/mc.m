%% <CODES.html CODES> / <reliability.html reliability> / mc
% _Monte-Carlo_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |res=CODES.reliability.mc(g,dim)| compute a Crude Monte-Carlo estimate
% of the probability that $g(\mathbf{X})\leq 0$. The |dim| random variables
% $\mathbf{X}$ are independent standard gaussian.
% * |res=CODES.reliability.mc(g,x_mc)| uses the user-defined Monte-Carlo
% sample x_mc.
% * |res=CODES.reliability.mc(...,param,value)| uses a list of
% parameters |param| and values |value| (see, <#params parameter table>).
%
% <html><a id="description"></a></html>
%% Description
% For a given limit state function $g$ and a joint PDF
% $\mathbf{f}_\mathbf{X}$, the probability of failure is:
%
% $$P_f=\int_\Omega I[g(\mathbf{x})\leq
% 0]\mathbf{f}_\mathbf{X}(\mathbf{x})\mathrm d\mathbf{x}$$
%
% A Crude Monte Carlo simulation with $n$ samples approximates the
% integral as:
%
% $$\displaystyle P_f=E[I[g(\mathbf{x})\leq 0]]\approx\displaystyle\frac{1}{n}\sum_{i=1}^nI\left[g(\mathbf{x}^{(i)})\leq0\right]$$
%
% In general, the probability of failure is dependent on
% distribution hyper-parameters $\theta$ and deterministic variables
% $\mathbf{z}$:
%
% $$P_f=\int I[g(\mathbf{x},\mathbf{z})\leq
% 0]\mathbf{f}_\mathbf{X}(\mathbf{x}|\theta)\mathrm d\mathbf{x}$$
%
% Derivatives of the probability of failure can be derived for
% hyper-parameters:
%
% $$\begin{array}{rcl}\displaystyle\frac{dP_f}{d\theta}&=&\displaystyle\frac{d}{d\theta}\int I[g(\mathbf{x},\mathbf{z})\leq 0]\mathbf{f}_\mathbf{X}(\mathbf{x}|\theta)d\mathbf{x}\\&=&\displaystyle\int I[g(\mathbf{x},\mathbf{z})\leq 0]\frac{d\ln \mathbf{f}_\mathbf{X}}{d\theta}f_\mathbf{X}(\mathbf{x}|\theta)d\mathbf{x}\\&\approx&\displaystyle\frac{1}{n}\sum_{i=1}^n I[g(\mathbf{x}^{(i)},\mathbf{z})\leq 0]\left.\frac{d\ln \mathbf{f}_\mathbf{X}}{d\theta}\right|_{\mathbf{x}^{(i)}}\end{array}$$
%
% and for deterministic variables (<#ref_lacaze Lacaze et
% al., 2015>):
%
% $$\begin{array}{rcl}\displaystyle\frac{dP_f}{d\mathbf{z}}&=&\displaystyle\frac{d}{d\mathbf{z}}\int I[g(\mathbf{x},z)\leq 0]f_\mathbf{X}(\mathbf{x}|\theta)d\mathbf{x}\\&=&\displaystyle-\int\frac{dg}{d\mathbf{z}}\delta[g(\mathbf{x},\mathbf{z})]f_\mathbf{X}(\mathbf{x}|\theta)d\mathbf{x}\\&\approx&\displaystyle-\frac{1}{n}\sum_{i=1}^n\tilde{\delta}[g(\mathbf{x}^{(i)},\mathbf{z})]\left.\frac{dg}{d\mathbf{z}}\right|_{\mathbf{x}^{(i)}}\end{array}$$
%
% Note that these sensitivities are cross-products of the probability of
% failure estimation and do not require any additional function call.
%
%% Parameters
% <html><table id="params" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'sampler'</span></td>
%     <td><tt>function_handle</tt>, { [ ] }</td>
%     <td>A function that returns realizations according to the desired distribution. For example, the default is <tt>@(N)normrnd(0,1,N,dim)</tt>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'Tinv'</span></td>
%     <td><tt>function_handle</tt>, { [ ] }</td>
%     <td>An inverse transformation function that transform realizations from a standard gaussian space into the desired space. For example, for an exponential space <tt>Tinv=@(u)expinv(normcdf(u),1)</tt>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'CoV'</span></td>
%     <td>positive, {<tt>Inf</tt>}</td>
%     <td>Coefficient of variation to be achieved (in %), see <a href=#description>Description</a>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'memory'</span></td>
%     <td>positive integer, {1e6}</td>
%     <td>When functions are vectorial in matlab, computing time is improved in exchange for memory use. To avoid memory crashes, no more than <span class="string">'memory'</span> samples are evaluated at once.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'alpha'</span></td>
%     <td>positive, {0.05}</td>
%     <td>Significance level for (1-alpha) confidence interval.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'limit'</span></td>
%     <td>positive integer, {1e9}</td>
%     <td>Maximum limit of samples allowed to be evaluated (in case CoV requested or actual Pf are too low).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'vectorial'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Whether the limit state function <tt>g</tt> is vectorial. Vectorization should always be used if possible and <span class="string">'vectorial'</span> set to <tt>true</tt>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'verbose'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Defines the verbose level.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'store'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Whether the Monte-Carlo sample should be stored and returned.</td>
%   </tr>
%   <tr>
%     <td><a id="sensitivities"></a><span class="string">'lnPDF'</span></td>
%     <td><tt>function_handle</tt></td>
%     <td> Log of joint PDF as a function of (x,theta) for dPfdtheta (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'dlnPDF'</span></td>
%     <td><tt>function_handle</tt></td>
%     <td>Derivative of log of joint PDF with respect to theta as a function of (x,theta)for dPfdtheta (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'theta'</span></td>
%     <td>real value</td>
%     <td>Theta value for dPfdtheta (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'nz'</span></td>
%     <td>positive integer</td>
%     <td>Number of deterministic variables for dPfdz. g is expected to return two outputs, g values and g gradients with respect to z (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'frac'</span></td>
%     <td>positive integer</td>
%     <td>Alpha fraction for dPfdz (see <a href='#demo'>Mini Tutorial</a> for an example and <a href='#ref_lacaze'>Lacaze et al., 2015</a>, for details).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'dirac'</span></td>
%     <td>{<span class="string">'gauss'</span>}, <span class="string">'tgauss'</span>, <span class="string">'poisson'</span>, <span class="string">'sinc'</span>, <span class="string">'bump'</span></td>
%     <td>Dirac approximation function (see <a href='#demo'>Mini Tutorial</a> for an example and <a href='#ref_lacaze'>Lacaze et al., 2015</a>, for details).</td>
%   </tr>
% </table></html>
%
%% Example
% Compute and plot a generalized "max-min" sample

g=@CODES.test.lin;
res=CODES.reliability.mc(g,2,'vectorial',true);
disp(res)

%%
% <html><a id='demo'></a></html>
%% Mini Tutorial
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_reliability_mc.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_reliability_mc.html">A mini tutorial of the capabilities of the <tt>mc</tt> function.</a><br></td>
%         </tr>
%     </table>
% </html>
%
%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_lacaze">
%   <span style="color:#005fce;">Lacaze et al. (2015)</span>: Lacaze, S.,
%   Brevault, L., Missoum, S., Balesdent, M. (2015). <i>Probability of
%   failure sensitivity with respect to decision variables</i>. Structural
%   and Multidisciplinary Optimization, First Published Online. <a
%   href="http://dx.doi.org/10.1007/s00158-015-1232-1">DOI</a>
%   </li>
% </ul></html>
%
%% See also
% <form.html form> | <iform.html iform> | <sorm.html sorm> | <subsect.html
% subset>
%
%%
% <html>Copyright &copy; 2015 Computational Optimal Design of Engineering System Laboratory. University of Arizona.</html>\n%%\n
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
