%% <CODES.html CODES> / <method.html sampling> / anti_lock
% _Generates an anti-locking sample_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |x_al=CODES.sampling.anti_lock(M,lb,ub)| finds an anti-locking sample 
% |x_al| on model |M| with lower bound |lb| and upper bound |ub|.
% * |x_al=CODES.sampling.anti_lock(...,param,value)| uses a list of
% parameters |param| and values |values| (_c.f._, <#params parameter
% table>).
% * |[x_al,adds]=CODES.sampling.anti_lock(...)| only if |nb=1| and |M.dim=2|,
% returns a (1 x 2) cell,|adds|, made of center and points to plot region
% boundary (see, <#demo_table demonstration> for more details). 
%
%% Description
% This function finds an anti-locking sample as introduced in <#ref_bas
% Basudhar (2011)>. A first optimization problem searches a region of maximum
% unbalance as:
%
% $$\begin{array}{rl}x_c=\mathop{\arg\max}\limits_{x}&\left(\mathop{\min}\limits_{i}\left|\left|x-x_{-}^{(i)}\right|\right|-\mathop{\min}\limits_{i}\left|\left|x-x_{+}^{(i)}\right|\right|\right)^2\\\textbf{s.t.} & s(x)=0\\&l_j\leq x_j\leq u_j\end{array}$$
%
% where $x_{-}^{(.)}$ and $x_{+}^{(.)}$ are the negative and
% positive samples,respectively, used to train $s$, a meta-model (an SVM in Basudhar's
% work). The numerical implementation of this optimization problem follows
% the steps highlighted in <#ref_lac Lacaze and Missoum (2014)> regarding the
% use of the Chebychev distance (infinite norm). This problem being made
% differentiable, it is then solve using multi-start SQP.
%
% Once the center is found, a second optimization is carried out:
%
% $$\begin{array}{rl}x_{al}=\mathop{\arg\min}\limits_{x}&\mathop{\mathrm{sgn}}\biggl[\mathop{\min}\limits_{i}\left|\left|x_c-x_{-}^{(i)}\right|\right|-\mathop{\min}\limits_{i}\left|\left|x_c-x_{+}^{(i)}\right|\right|\biggr]s(x)\\\textbf{s.t.} & \left|\left|x-x_c\right|\right|-R\leq 0\\&l_j\leq x_j\leq u_j\end{array}$$
%
% where:
% 
% $$R=\frac{1}{4}\biggl|\mathop{\min}\limits_{i}\left|\left|x_c-x_{-}^{(i)}\right|\right|-\mathop{\min}\limits_{i}\left|\left|x_c-x_{+}^{(i)}\right|\right|\biggr|$$
%
%% Parameters
% <html><table id="params" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'nb'</span></td>
%     <td>positive integer, {1}</td>
%     <td>Number of anti-locking samples requested (<i>nb</i>&ge;2 is refered to as parallel, unpublished)</td>
%   </tr>
%   <tr>
%     <td><span class="string">'intensity'</span></td>
%     <td>positive integer, {30}</td>
%     <td>Number of starting points for the multi-start SQP algorithm</td>
%   </tr>
%   <tr>
%     <td><span class="string">'UseParallel'</span></td>
%     <td>logical, {<tt>M.UseParallel</tt>}</td>
%     <td>Parallel set up usage</td>
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
% </table></html>
%
% <html>In addition, options from
% <a href="http://www.mathworks.com/help/gads/multistart-class.html"><tt>MultiStart</tt></a>
% can be used as well, when <span class="string">'MultiStart'</span> is set to <span class="string">'MATLAB'</span>.</html>
%
%% Example
% Compute and plot an anti-locking sample

DOE=CODES.sampling.cvt(20,2,'lb',[-5 -5],'ub',[5 5]);
svm=CODES.fit.svm(DOE,DOE(:,1)-DOE(:,2));
x_al=CODES.sampling.anti_lock(svm,[-5 -5],[5 5]);
figure('Position',[200 200 500 500])
svm.isoplot('lb',[-5 -5],'ub',[5 5])
plot(x_al(1),x_al(2),'ms')

%% Mini Tutorial
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table id="demo_table" border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_method_anti_lock.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_method_anti_lock.html">A mini tutorial of the capabilities of the <tt>anti_lock</tt> function.</a><br></td>
%         </tr>
%     </table>
% </html>
%
%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_bas"><span style="color:#005fce;">Basudhar (2011)</span>:
%   Basudhar A., (2011) <i>Computational optimal design and uncertainty
%   quantification of complex systems using explicit decision
%   boundaries</i>. The University of Arizona - <a href="http://dx.doi.org/10150/201491">DOI</a></li>
%   <li id="ref_lac"><span style="color:#005fce;">Lacaze and Missoum
%   (2014)</span>: Lacaze S., Missoum S., (2014) <i>A generalized "max-min"
%   sample for surrogate update</i>. Structural and Multidisciplinary
%   Optimization 49(4):683-687 - <a href="http://dx.doi.org/10.1007/s00158-013-1011-9">DOI</a></li>
% </ul></html>
%
%% See also
% <edsd.html edsd> | <gmm.html gmm> | <mm.html mm>
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
