%% <CODES.html CODES> / <reliability.html reliability> / iform
% _Inverse first-order reliability method_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |res=CODES.reliability.iform(g,dim,beta)| search for the Minimum
% Performance Target Point (MPTP) at a given beta. The dimension |dim| of
% the problem must be specified.
% * |res=CODES.reliability.iform(...,param,value)| uses a list of
% parameters |param| and values |value| (see, <#params parameter table>)
%
% <html><a id="description"></a></html>
%% Description
% For a given target probability of failure associated with a target
% reliability index $\beta_T$, the inverse FORM approach finds the minimum
% performace target point (MPTP) $\mathbf{u}_{mptp}$ by solving the
% following optimization problem (PMA approach):
%
% $$\begin{array}{rl}\mathbf{u}_{mptp}=\mathop{\arg\min}\limits_{\mathbf{u}}&g\left(T^{-1}\left(\mathbf{u}\right)\right)\\\mbox{s.t.} & \mathbf{u}\mathbf{u}^T=\beta_T^2\end{array}$$
%
% For distribution hyper-parameters$\theta$ and deterministic variables
% $\mathbf{z}$, the probabilistic performace measure (PPM) is defined as:
%
% $$G(\mathbf{z},\theta)=g(\mathbf{x}_{mptp}(\mathbf{z},\theta),\mathbf{z})$$
%
% Sensitivities of the PPM $G$ are:
%
% $$\displaystyle\frac{dG}{d\theta}=\frac{dT^{-1}}{d\theta}\nabla_\mathbf{x}g(\mathbf{x}_{mptp})$$
%
% $$\displaystyle\frac{dG}{d\mathbf{z}}=\frac{dg}{d\mathbf{z}}$$
%
% <html><a id="solver"></a></html>
%% Solvers
% Currently available solvers:
%
% <html><ul>
%   <li><span class="string">'sqp'</span>, matlab fmincon using sqp algorithm</li>
% 	<li><span class="string">'amv'</span>, <a href=#ref_wu>Wu
% 	(1984)</a></li>
% 	<li><span class="string">'cmv'</span>, <a href=#ref_youn>Youn et al. (2003)</a></li>
% 	<li><span class="string">'hmv'</span>, <a href=#ref_youn>Youn et al. (2003)</a></li>
% </ul></html>
%
%% Parameters
% <html><table id="params" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'solver'</span></td>
%     <td>{<span class="string">'sqp'</span>}, <span class="string">'amv'</span>, <span class="string">'cmv'</span>, <span class="string">'hmv'</span></td>
%     <td>Defines which RIA solver to use, see <a href="solver">Solvers</a>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'Tinv'</span></td>
%     <td><tt>function_handle</tt>, { [ ] }</td>
%     <td>An inverse transformation function that transform realizations from a standard gaussian space into the desired space. For example, for an exponential space <tt>Tinv=@(u)expinv(normcdf(u),1)</tt>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'LS_grad'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Wether the limit state function <tt>g</tt> also return gradients with respect to x.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'rel_diff'</span></td>
%     <td>positive integer, {1e-5}</td>
%     <td>Perturbation used for finite difference.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'eps'</span></td>
%     <td>positive integer, {1e-4}</td>
%     <td>Convergence tolerance.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'iter_max'</span></td>
%     <td>positive integer, {100}</td>
%     <td>Maximum number of iterations.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'vectorial'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Wether the limit state function <tt>g</tt> is vectorial.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'display'</span></td>
%     <td>{<span class="string">'none'</span>}, <span class="string">'final'</span>, <span class="string">'iter'</span></td>
%     <td>Defines the verbose level.</td>
%   </tr>
%   <tr>
%     <td><a id="sensitivities"></a><span class="string">'gz'</span></td>
%     <td><tt>function_handle</tt></td>
%     <td>g as a function of x and z, used for dPPM/dz (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'dgdz'</span></td>
%     <td><tt>function_handle</tt></td>
%     <td>dg/dz as a function of x and z, used for dPPM/dz (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'z'</span></td>
%     <td>real value</td>
%     <td>z value, used for dPPM/dz (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'T'</span></td>
%     <td><tt>function_handle</tt></td>
%     <td>Transformation T as a function of x and theta, used for dPPM/dtheta (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'dTdx'</span></td>
%     <td><tt>function_handle</tt></td>
%     <td>dT/dx as a function of x and theta, used for dPPM/dtheta (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'Tinvtheta'</span></td>
%     <td><tt>function_handle</tt></td>
%     <td>Inverse transformation Tinv as a function of u and theta, used for dPPM/dtheta (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'dTinvdtheta'</span></td>
%     <td><tt>function_handle</tt></td>
%     <td>dTinv/dtheta as a function of u and theta, used for dPPM/dtheta (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'theta'</span></td>
%     <td>real value</td>
%     <td>theta value, used for dPPM/dtheta (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
% </table></html>
%
%% Example
% Compute and plot a generalized "max-min" sample

g=@CODES.test.lin;
res=CODES.reliability.iform(g,2,2.5);
disp(res)

%%
% <html><a id="demo"></a></html>
%% Demonstration
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_reliability_iform.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_reliability_iform.html">A complete demonstration of the capabilities of the <tt>iform</tt> function.</a><br></td>
%         </tr>
%     </table>
% </html>
%
%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_wu">
%   <span style="color:#005fce;">Wu (1984)</span>: Wu, Y.-T. (1984).
%   <i>Efficient methods for mechanical and structural reliability analysis
%   and design (safety-index, fatigue, failure)</i>. The University of
%   Arizona. <a
%   href="http://arizona.openrepository.com/arizona/handle/10150/187685">link</a>
%   </li>
%   <li id="ref_youn">
%   <span style="color:#005fce;">Youn et al. (2003)</span>: Youn, B. D.,
%   Choi, K. K., & Park, Y. H. (2003). <i>Hybrid Analysis Method for
%   Reliability-Based Design Optimization</i>. Journal of Mechanical
%   Design, 125(2), 221. <a
%   href="http://dx.doi.org/10.1115/1.1561042">DOI</a>
%   </li>
% </ul></html>
%
%% See also
% <form.html form> | <sorm.html sorm> | <mc.html mc> | <subsect.html
% subset>
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
