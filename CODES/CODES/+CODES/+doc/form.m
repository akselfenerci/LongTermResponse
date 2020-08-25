%% <CODES.html CODES> / <reliability.html reliability> / form
% _First Order Reliability Method_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |res=CODES.reliability.form(g,dim)| computes a FORM estimate of the
% probability that $g(\mathbf{X})\leq 0$. The |dim| random variables
% $\mathbf{X}$ are independent standard gaussian.
% * |res=CODES.reliability.form(...,param,value)| uses a list of
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
% An approximation of $P_f$ is given by the First Order Reliability
% Method (FORM) which assumes that the limit state function is linear in
% the standard normal space. It is based on the notion of most probable
% point (MPP) $\mathbf{u}_{mpp}$ which is found by solving the following
% optimization problem (RIA approach):
%
% $$\begin{array}{rl}\mathbf{u}_{mpp}=\mathop{\arg\min}\limits_{\mathbf{u}}&\frac{1}{2}\mathbf{u}\mathbf{u}^T\\\mbox{s.t.} & g\left(T^{-1}\left(\mathbf{u}\right)\right)\leq 0\end{array}$$
%
% The reliability index $\beta$ is defined as the algebraic distance from
% the origin to the MPP in the standard normal space. The probability of
% failure is then approximated as:
%
% $P_f=\Phi(-\beta)$
%
% Sensitivities of $\beta$ with respect to distribution hyper-parameters
% $\theta$ and deterministic variables $\mathbf{z}$ are defined as:
%
% $$\displaystyle\frac{d\beta}{d\theta}=\frac{\mathbf{u}_{mpp}}{\beta}\frac{dT}{d\theta}$$
%
% $$\displaystyle\frac{d\beta}{d\mathbf{z}}=\frac{1}{||\nabla_\mathbf{u}g(T^{-1}(\mathbf{u}_{mpp}))||}\frac{dg}{d\mathbf{z}}$$
%
% <html><a id="solver"></a></html>
%% Solvers
% Currently available solvers:
%
% <html><ul>
%   <li><span class="string">'sqp'</span>, matlab fmincon using sqp algorithm</li>
% 	<li><span class="string">'hl-rf'</span>, <a href=#ref_hl>Hasofer & Lind (1974)</a> and <a
% 	href=#ref_rf>Rackwitz & Fiessler (1978)</a></li>
% 	<li><span class="string">'ihl-rf'</span>, <a href=#ref_liu>Liu & Der Kiureghian (1991)</a></li>
% 	<li><span class="string">'jhl-rf'</span>, <a href=#ref_zhang>Zhang & Der Kiureghian (1995)</a></li>
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
%     <td>{<span class="string">'sqp'</span>}, <span class="string">'hl-rf'</span>, <span class="string">'ihl-rf'</span>, <span class="string">'jhl-rf'</span></td>
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
%     <td>Whether the limit state function <tt>g</tt> also return gradients with respect to x.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'rel_diff'</span></td>
%     <td>positive, {1e-5}</td>
%     <td>Perturbation used for finite difference.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'eps'</span></td>
%     <td>positive, {1e-4}</td>
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
%     <td>Whether the limit state function <tt>g</tt> is vectorial.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'display'</span></td>
%     <td>{<span class="string">'none'</span>}, <span class="string">'final'</span>, <span class="string">'iter'</span></td>
%     <td>Defines the verbose level.</td>
%   </tr>
%   <tr>
%     <td><a id="sensitivities"></a><span class="string">'gz'</span></td>
%     <td><tt>function_handle</tt></td>
%     <td>g as a function of x and z, used for dPf/dz (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'dgdz'</span></td>
%     <td><tt>function_handle</tt></td>
%     <td>dg/dz as a function of x and z, used for dPf/dz (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'z'</span></td>
%     <td>real value</td>
%     <td>z value, used for dPf/dz (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'T'</span></td>
%     <td><tt>function_handle</tt></td>
%     <td>Transformation T (inverse of Tinv) as a function of x and theta, used for dPf/dtheta (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'dTdtheta'</span></td>
%     <td><tt>function_handle</tt></td>
%     <td>dT/dtheta as a function of x and theta, used for dPf/dtheta (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'theta'</span></td>
%     <td>real value</td>
%     <td>theta value, used for dPf/dtheta (see <a href='#demo'>Mini Tutorial</a> for an example).</td>
%   </tr>
% </table></html>
%
%% Example
% Compute and plot a generalized "max-min" sample

g=@CODES.test.lin;
res=CODES.reliability.form(g,2);
disp(res)

%%
% <html><a id='demo'></a></html>
%% Mini Tutorial
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_reliability_form.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_reliability_form.html">A mini tutorial of the capabilities of the <tt>form</tt> function.</a><br></td>
%         </tr>
%     </table>
% </html>
%
%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_hl">
%   <span style="color:#005fce;">Hasofer & Lind (1974)</span>: Hasofer, A.
%   M., & Lind, N. C. (1974). <i>An exact and invariant first-order
%   reliability format</i>. Journal of Engineering Mechanics, 100(1),
%   111-121.
%   </li>
%   <li id="ref_rf">
%   <span style="color:#005fce;">Rackwitz & Fiessler (1978)</span>:
%   Rackwitz, R. & Fiessler, B. (1978). <i>Structural reliability under
%   combined random load sequences</i>. Computers & Structures, 9(5),
%   489-494. <a
%   href="http://dx.doi.org/10.1016/0045-7949(78)90046-9">DOI</a>
%   </li>
%   <li id="ref_liu">
%   <span style="color:#005fce;">Liu & Der Kiureghian (1991)</span>: Liu,
%   P.-L., & Der Kiureghian, A. (1991). <i>Optimization algorithms for
%   structural reliability</i>. Structural Safety, 9(3), 161-177. <a
%   href="http://dx.doi.org/10.1016/0167-4730(91)90041-7">DOI</a>
%   </li>
%   <li id="ref_zhang">
%   <span style="color:#005fce;">Zhang & Der Kiureghian (1995)</span>:
%   Zhang, Y., & Der Kiureghian, A. (1995). <i>Two Improved Algorithms for
%   Reliability Analysis</i>. In Proceedings of the sixth IFIP WG7.5
%   working conference on reliability and optimization of structural
%   systems (pp. 297-304). <a
%   href="http://dx.doi.org/10.1007/978-0-387-34866-7_3"2>DOI</a>
%   </li>
% </ul></html>
%
%% See also
% <form.html iform> | <sorm.html sorm> | <sorm.html sorm> | <subsect.html
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
