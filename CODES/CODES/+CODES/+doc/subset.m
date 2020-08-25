%% <CODES.html CODES> / <reliability.html reliability> / subset
% _Subset Simulations_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |res=CODES.reliability.subset(g,dim)| compute a Subset Simulation
% estimate of the probability that $g(\mathbf{X})\leq 0$. The |dim| random
% variables $\mathbf{X}$ are independent standard gaussian.
% * |res=CODES.reliability.subset(...,param,value)| uses a list of
% parameters |param| and values |value| (see, <#params parameter table>)
%
% <html><a id="approx"></a></html>
%% Description
% For a given limit state function $g$ and a joint PDF
% $\mathbf{f}_\mathbf{X}$, the probability of failure is:
%
% $$P_f=\int_\Omega I[g(\mathbf{x})\leq
% 0]\mathbf{f}_\mathbf{X}(\mathbf{x})\mathrm d\mathbf{x}$$
%
% A Subset Simulation (<#ref_au Au & Beck, 2001>) estimates the probability
% of failure as a product of larger conditional probabilities:
%
% $$P_f=\prod P_f^{(i)}$$
%
% where $P_f^{(i)}$ is the $i^{th}$ intermediate probability of
% failure. These intermediate probabilities are estimated by successive
% Markov-Chain Monte Carlo simulations (<#ref_au Au & Beck, 2001>).
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
% $$\begin{array}{rcl}\displaystyle\frac{dP_f}{d\theta}&=&\displaystyle\frac{d}{d\theta}\int I[g(\mathbf{x},\mathbf{z})\leq 0]f_\mathbf{X}(\mathbf{x}|\theta)d\mathbf{x}\\&=&\displaystyle\int I[g(\mathbf{x},\mathbf{z})\leq 0]\frac{d\ln f_\mathbf{X}}{d\theta}f_\mathbf{X}(\mathbf{x}|\theta)d\mathbf{x}\end{array}$$
%
% An expression of sensitivity estimates with respect to $\theta$ as a
% cross-product of the Subset Simulation can be found in <#ref_song Song et
% al. (2009)>.
%
% $$\begin{array}{rcl}\displaystyle\frac{dP_f}{d\mathbf{z}}&=&\displaystyle\frac{d}{d\mathbf{z}}\int I[g(\mathbf{x},\mathbf{z})\leq 0]f_\mathbf{X}(\mathbf{x}|\theta)d\mathbf{x}\\&=&\displaystyle-\int\frac{dg}{d\mathbf{z}}\delta[g(\mathbf{x},\mathbf{z})]f_\mathbf{X}(\mathbf{x}|\theta)d\mathbf{x}\end{array}$$
% 
% An expression of sensitivity estimates with respect to $\mathbf{z}$ as a
% cross-product of the Subset Simulation can be found in <#ref_lacaze
% Lacaze et al. (2015)>.
%
%% Parameters
% <html><table id="params" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'PDFs_target'</span></td>
%     <td><tt>function_handle</tt>, { [ ] }</td>
%     <td>Target marginal pdfs. For a <tt>(n x dim)</tt> sample, <tt>PDFs_target(x)</tt> should return a <tt>(n x dim)</tt> matrix of marginal PDF values. Default is <tt>@(x)normpdf(x)</tt>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'sampler'</span></td>
%     <td><tt>function_handle</tt>, { [ ] }</td>
%     <td>A function to get samples for the first step. Default is <tt>@(N)normrnd(0,1,N,dim)</tt>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'prop_rand'</span></td>
%     <td><tt>function_handle</tt>, { [ ] }</td>
%     <td>Proposal random sampler. For a <tt>(n x dim)</tt> sample <tt>x</tt>, returns a <tt>(n x dim)</tt> sample of proposed candidates. By default, uses normal with mean <tt>x</tt> and standard deviation 1.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'CoV'</span></td>
%     <td>numeric, {1}</td>
%     <td>Coefficient in % to be achieved on the CMC estimate of the first intermediate probability.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'N'</span></td>
%     <td>numeric, { [ ] }</td>
%     <td>Number of samples to be used at the first step. If default, uses <span class="string">'N'</span> such that <span class="string">'CoV'</span> is satisfied.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'CoV_bound'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Wether the bound of the estimator coefficient of variation should be computed. Note that it might substantially increase the computational time.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'step_Pf'</span></td>
%     <td>numeric, {0.1}</td>
%     <td>Step probability of failure.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'verbose'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Verbose level.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'burnin'</span></td>
%     <td>positive integer, {0}</td>
%     <td>Number of samples to be &ldquo;burned&rdquo; at the begining.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'store'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Wether the Monte-Carlo sample should be stored and returned.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'Pf_limit'</span></td>
%     <td>positive integer, {1e-8}</td>
%     <td>Lowest probability to be estimated.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'vectorial'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Wether the limit state function <tt>g</tt> is vectorial or not. Vectorization should always be used if possible and <span class="string">'vectorial'</span> set to <tt>true</tt>.</td>
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
%     <td>Alpha fraction for dPfdz (see <a href='#demo'>Mini Tutorial</a> for an example and <a href='#ref_lacaze'>Lacaze et al.</a> for details).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'dirac'</span></td>
%     <td>{<span class="string">'gauss'</span>}, <span class="string">'tgauss'</span>, <span class="string">'poisson'</span>, <span class="string">'sinc'</span>, <span class="string">'bump'</span></td>
%     <td>Dirac approximation function (see <a href='#demo'>Mini Tutorial</a> for an example and <a href='#ref_lacaze'>Lacaze et al.</a> for details).</td>
%   </tr>
% </table></html>
%
%% Example
% Compute and plot a generalized "max-min" sample

g=@CODES.test.lin;
res=CODES.reliability.subset(g,2,'vectorial',true);
disp(res)

%%
% <html><a id="demo"></a></html>
%% Demonstration
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_reliability_subset.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_reliability_subset.html">A complete demonstration of the capabilities of the <tt>subset</tt> function.</a><br></td>
%         </tr>
%     </table>
% </html>
%
%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_au">
%   <span style="color:#005fce;">Au & Beck (2001)</span>: Au, S.-K., &
%   Beck, J. L. (2001). <i>Estimation of small failure probabilities in
%   high dimensions by subset simulation</i>. Probabilistic Engineering
%   Mechanics, 16(4), 263-277. <a
%   href="http:dx.doi.org/10.1016/S0266-8920(01)00019-4">DOI</a>
%   </li>
%   <li id="ref_song">
%   <span style="color:#005fce;">Song et al. (2009)</span>: Song, S., Lu,
%   Z., & Qiao, H. (2009). <i>Subset simulation for structural reliability
%   sensitivity analysis</i>. Reliability Engineering & System Safety,
%   94(2), 658-665. <a
%   href="http://dx.doi.org/10.1016/j.ress.2008.07.006">DOI</a>
%   </li>
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
% <form.html form> | <iform.html iform> | <sorm.html sorm> | <mc.html mc>
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
