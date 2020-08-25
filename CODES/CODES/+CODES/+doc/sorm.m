%% <CODES.html CODES> / <reliability.html reliability> / sorm
% _Second-order reliability method_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |res=CODES.reliability.sorm(g,dim)| compute a SORM estimate of the
% probability that $g(\mathbf{X})\leq 0$. The |dim| random variables
% $\mathbf{X}$ are independent standard gaussian.
% * |res=CODES.reliability.sorm(...,param,value)| uses a list of
% parameters |param| and values |value| (see, <#params parameter table>)
%
% <html><a id="approx"></a></html>
%% Approximations
% For a given limit state function $g$ and a joint PDF
% $\mathbf{f}_\mathbf{X}$, the probability of failure is:
%
% $$P_f=\int_\Omega I[g(\mathbf{x})\leq
% 0]\mathbf{f}_\mathbf{X}(\mathbf{x})\mathrm d\mathbf{x}$$
%
% An approximation of $P_f$ is given by the Second Order Reliability
% Method (SORM) which assumes that the limit state function is quadratic in
% the standard normal space.
%
% The SORM approximations available in this toolbox are:
%
% <html><ul>
%   <li><span class="string">'Breitung'</span>, <a href=#ref_Breitung>Wu (1984)</a></li>
% 	<li><span class="string">'Tvedt'</span>, <a href=#ref_Tvedt>Tvedt (1990)</a></li>
% 	<li><span class="string">'Koyluoglu'</span>, <a href=#ref_koy>Köylüoǧlu & Nielsen (1994)</a></li>
% 	<li><span class="string">'Cai'</span>, <a href=#ref_cai>Cai & Elishakoff (1994)</a></li>
% 	<li><span class="string">'Zhao'</span>, <a href=#ref_zhao>Zhao & Ono (1999)</a></li>
% 	<li><span class="string">'Subset'</span>, uses Subset Simulations <a
% 	href=#ref_au>Au & Beck (2001)</a> on a second order Taylor
% 	expansion</li>
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
%     <td><span class="string">'Tinv'</span></td>
%     <td><tt>function_handle</tt>, { [ ] }</td>
%     <td>An inverse transformation function that transform realizations from a standard gaussian space into the desired space. For example, for an exponential space <tt>Tinv=@(u)expinv(normcdf(u),1)</tt>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'approx'</span></td>
%     <td>{<span class="string">'Breitung'</span>}, <span class="string">'Tvedt'</span>, <span class="string">'Koyluoglu'</span>, <span class="string">'Cai'</span>, <span class="string">'Zhao'</span>, <span class="string">'Subset'</span></td>
%     <td>Defines which RIA solver to use, see <a href="approx">Approximations</a>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'rel_diff'</span></td>
%     <td>positive integer, {1e-5}</td>
%     <td>Perturbation used for finite difference.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'res_form'</span></td>
%     <td>structure, { [ ] }</td>
%     <td>The result of a call to <tt><a href=form.m>form</a></tt>. If empty, runs <tt><a href=form.m>form</a></tt> with default.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'H'</span></td>
%     <td>positive integer, { [ ] }</td>
%     <td>Hessian matrix in the U space. If not provided, uses finite differences. Usefull after a first run, for recall.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'grad'</span></td>
%     <td>positive integer, { [ ] }</td>
%     <td>Gradient in the U space. If not provided, uses finite differences. Usefull after a first call run, for recall.</td>
%   </tr>
% </table></html>
%
%% Example
% Compute and plot a generalized "max-min" sample

g=@CODES.test.lin;
res=CODES.reliability.sorm(g,2);
disp(res)

%% Mini Tutorial
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_reliability_sorm.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_reliability_sorm.html">A mini tutorial of the capabilities of the <tt>sorm</tt> function.</a><br></td>
%         </tr>
%     </table>
% </html>
%
%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_Breitung">
%   <span style="color:#005fce;">Breitung (1984)</span>: Breitung, K.
%   (1984). <i>Asymptotic approximations for multinormal integrals</i>.
%   Journal of Engineering Mechanics, 110(3), 357-366.
%   </li>
%   <li id="ref_Tvedt">
%   <span style="color:#005fce;">Tvedt (1990)</span>: Tvedt, L. (1990).
%   <i>Distribution of Quadratic Forms in Normal Space - Application to
%   Structural Reliability</i>. Journal of Engineering Mechanics, 116(6),
%   1183-1197. <a
%   href="http://dx.doi.org/10.1061/(ASCE)0733-9399(1990)116:6(1183)">DOI</a>
%   </li>
%   <li id="ref_koy">
%   <span style="color:#005fce;">Köylüoǧlu & Nielsen (1994)</span>:
%   Köylüoǧlu, H. U., & Nielsen, S. R. K. (1994). <i>New approximations for
%   SORM integrals</i>. Structural Safety, 13(4), 235-246. <a
%   href="http://dx.doi.org/10.1016/0167-4730(94)90031-0">DOI</a>
%   </li>
%   <li id="ref_cai">
%   <span style="color:#005fce;">Cai & Elishakoff (1994)</span>: Cai, G.
%   Q., & Elishakoff, I. (1994). <i>Refined second-order reliability
%   analysis</i>. Structural Safety, 14(4), 267-276. <a
%   href="http://dx.doi.org/10.1016/0167-4730(94)90015-9">DOI</a>
%   </li>
%   <li id="ref_zhao">
%   <span style="color:#005fce;">Zhao & Ono (1999)</span>: Zhao, Y.-G., &
%   Ono, T. (1999). <i>New Approximations for SORM: Part 1</i>. Journal of
%   Engineering Mechanics, 125(1), 79-85. <a
%   href="http://10.1061/(ASCE)0733-9399(1999)125:1(79)">DOI</a>
%   </li>
%   <li id="ref_au">
%   <span style="color:#005fce;">Au & Beck (2001)</span>: Au, S.-K., &
%   Beck, J. L. (2001). <i>Estimation of small failure probabilities in
%   high dimensions by subset simulation</i>. Probabilistic Engineering
%   Mechanics, 16(4), 263-277. <a
%   href="http:dx.doi.org/10.1016/S0266-8920(01)00019-4">DOI</a>
%   </li>
% </ul></html>
%
%% See also
% <form.html form> | <iform.html iform> | <mc.html mc> | <subset.html
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
