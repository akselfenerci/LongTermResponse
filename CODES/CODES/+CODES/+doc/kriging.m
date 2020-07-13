%% <CODES.html CODES> / <fit_main.html fit> / kriging
% _Train a Kriging_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
% <html><a id="syntax"></a></html>
%% Syntax
% * |kr=CODES.fit.kriging(x,y)| builds a kriging based on the training set
% |(x,y)|.
% * |kr=CODES.fit.kriging(...,param,value)| uses a list of parameters
% |param| and values |value| (_c.f._, <#params parameter table>).
%
% <html><a id="description"></a></html>
%% Description
% For a training set $\left[\underline{\mathbf{X}},\underline{Y}\right]$
% made of pairs $\mathbf{x}^{(i)}$ and $y^{(i)}$ such that:
%
% $$y^{(i)}=f\left(\mathbf{x}^{(i)}\right)$$
%
% and a mean function $m$ and an auto-correlation function $K_\theta$, the
% covariance function is defined as:
%
% $$k\left(\mathbf{x},\mathbf{x}^\prime\right)=\sigma_Y^2K_\theta\left(\mathbf{x},\mathbf{x}^\prime\right)+\sigma_n^2\mathbf{I}\left[\mathbf{x}=\mathbf{x}^\prime\right]$$
%
% where $\sigma_Y^2$ is the Kriging variance and $\sigma_n^2$ is the
% inherent variance, also referred to as nugget or observation variance.
%
% The training covaraince matrix and mean matrix are defined as:
%
% $$\Sigma_{tr}=\left[\begin{array}{ccc}k\left(\mathbf{x}^{(1)},\mathbf{x}^{(1)}\right) & \dots & k\left(\mathbf{x}^{(1)},\mathbf{x}^{(n)}\right)\\\vdots & \ddots & \vdots\\k\left(\mathbf{x}^{(n)},\mathbf{x}^{(1)}\right) & \dots & k\left(\mathbf{x}^{(n)},\mathbf{x}^{(n)}\right)\end{array}\right]$$
%
% $$\mu_{tr}=\left[m\left(\mathbf{x}^{(1)}\right),\dots,m\left(\mathbf{x}^{(n)}\right)\right]$$
%
% The Kriging prediction and prediction standard error are defined as:
%
% $$\widetilde{f}\left(\mathbf{x}\right)=m\left(\mathbf{x}\right)+\left(\underline{Y}^T-\mu_{tr}\right)\Sigma_{tr}^{-1}\Sigma_{\mathbf{x}}^T$$
%
% $$\widetilde{f}^{se}\left(\mathbf{x}\right)=\sqrt{k\left(\mathbf{x},\mathbf{x}\right)-\Sigma_\mathbf{x}\Sigma_{tr}^{-1}\Sigma_\mathbf{x}^T}$$
%
% <html><a id="covariance"></a><h3>Correlation functions</h3></html>
%
% One covariance function is available:
%
% * Gaussian:
%
% $$K_\theta(\mathbf{x},\mathbf{x}^\prime)=\exp\left[\frac{||\mathbf{x}-\mathbf{x}^\prime||^2}{2\theta^2}\right]$$
%
% <html><a id="mean"></a><h3>Mean Functions</h3></html>
%
% One mean function is available:
%
% * 0 order polynomial:
%
% $$m\left(\mathbf{x}\right)=\beta$$
%
% <html><a id="solvers"></a><h3>Solvers</h3></html>
%
% Two solvers are available:
%
% <html><ul>
%   <li><span class="string">'CODES'</span>: An implementation from
%   scratch.</li>
%   <li><span class="string">'DACE'</span> Uses the <a
%   href="http://www.imm.dtu.dk/~hbni/dace">DACE Toolbox</a> with minor
%   numerical improvement in the prediction.</li>
% </ul></html>
%
% <html><a id="training"></a></html>
%% Training Options
% <html><table id="params" style="border: none">
%   <tr>
%     <th><span class="ms">param</span></th>
%     <th><span class="ms">value</span></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'scale'</span></td>
%     <td>{<span class="string">'square'</span>}, <span class="string">'circle'</span>, <span class="string">'none'</span></td>
%     <td>Define scaling method for the inputs (<i>c.f.</i>, <a href=#scaling>Scaling</a> for details).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'UseParallel'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Switch to use parallel settings.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'theta'</span></td>
%     <td>numeric, { [ ] }</td>
%     <td>Value for kernel parameter. If [ ], should be calibrated.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'delta_2'</span></td>
%     <td>numeric, {<tt>0</tt>}</td>
%     <td>Only if <span class="string">'regression'</span> set to <tt>true</tt>. Value for &ldquo;nugget&rdquo; parameter. If left to default, should be calibrated.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'mean_fun'</span></td>
%     <td>{<span class="string">'poly0'</span>}</td>
%     <td>Mean value function, see <a href=#mean>Mean functions</a>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'cov_fun'</span></td>
%     <td>{<span class="string">'corr'</span>}</td>
%     <td>Correlation function (also referred to as kernel or auto-correlation function), see <a href=#covariance>Correlation functions</a>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'scale_y'</span></td>
%     <td>{<span class="string">'square'</span>}, <span class="string">'circle'</span>, <span class="string">'none'</span></td>
%     <td>Define scaling method for the ouputs (<i>c.f.</i>, <a href=meta.html#scaling>Scaling (meta)</a> for details)</td>
%   </tr>
%   <tr>
%     <td><span class="string">'solver'</span></td>
%     <td>{<span class="string">'CODES'</span>} or <span class="string">'DACE'</span></td>
%     <td>Type of solver to use to train the Kriging, see <a href=#solvers>Solvers</a>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'regression'</span></td>
%     <td>logical {<tt>false</tt>}</td>
%     <td>Whether regression kriging should be used. This is achieved by adding a &ldquo;nugget&rdquo; <span class="string">'delta_2'</span> on the diagonal of the correlation matrix, see <a href=#description>Description</a>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'display'</span></td>
%     <td>logical {<tt>true</tt>}</td>
%     <td>Wether information should be displayed. For now, only display warning if correlation matrix needs to be conditioned (further than <span class="string">'delta_2'</span>).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'theta_min'</span></td>
%     <td>numeric, { [ ] }</td>
%     <td>Only if <span class="string">'solver'</span> set to <span class="string">'DACE'</span>. Lower bound for the <span class="string">'theta'</span> search.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'theta_max'</span></td>
%     <td>numeric, { [ ] }</td>
%     <td>Only if <span class="string">'solver'</span> set to <span class="string">'DACE'</span>. Upper bound for the <span class="string">'theta'</span> search.</td>
%   </tr>
% </table></html>
%
% <html><a id="evaluation"></a></html>
%% Evaluation and Post-Processing
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table id="demo_table" border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="kriging_method.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="kriging_method.html">Capabilities of a <tt>Kriging</tt> object.</a><br></td>
%         </tr>
%     </table>
% </html>
%
% <html><a id="example"></a></html>
%% Mini tutorial
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table id="demo_table" border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_fit_kriging.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_fit_kriging.html">A mini tutorial of the capabilities of the <tt>Kriging</tt> class.</a><br></td>
%         </tr>
%     </table>
% </html>
%
%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_dace"><a href="http://www.imm.dtu.dk/~hbni/dace">DACE Toolbox</a></li>
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
