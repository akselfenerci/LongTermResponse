%% <CODES.html CODES> / <method.html sampling> / edsd
% _Perform Explicit Design Space Decomposition_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |Mcol=CODES.sampling.edsd(f,M,lb,ub)| performs EDSD on |f|, using an
% initial meta-model |M|, within |lb| and |ub| and returns the collection of
% meta-model |Mcol|.
% * |Mcol=CODES.sampling.edsd(...,param,value)| uses a list of
% parameters |param| and values |value| (see <#params parameter table>).
%
%% Description
% This function performs Explicit Design Space Decomposition (EDSD) as
% described in <#ref_bas Basudhar and Missoum (2010)> and <#ref_bas
% Basudhar (2011)>. Essentially, EDSD sequentially refines an initial
% meta-model (an SVM in Basudhar's work) using <mm.html max-min> and
% <anti_lock.html anti-locking> samples. Please refer to their
% specific documentation for details. This implementation relies on the
% numerical advances presented in <#ref_lac Lacaze and Missoum (2014)>.
%
% In <#ref_bas2 Basudhar and Missoum (2008)>, a convergence metric is
% introduced based on the change of class of "convergence" samples from one
% iteration to another:
%
% $$r_k=\frac{\textrm{\# samples with different class from }k-1\textrm{ to }k}{\textrm{total \# of samples}}$$
%
% This ratio is further fitted by an exponential model:
%
% $$r_k\approx A\mbox{e}^{Bk}$$
%
% <html>where <i>A</i> and <i>B</i> (&le;0) are constants to be determined and
% <i>k</i> the iteration considered. If <span
% class="string">'conv_coef'</span> is set to <span
% class="string">'fit'</span>, <i>A</i> and <i>B</i> are chosen so as to
% minimize the least square error. If <span
% class="string">'conv_coef'</span> is set to <span
% class="string">'direct'</span> at iteration <i>k</i>, <i>A</i> and
% <i>B</i> are chosen such that:</html>
%
% $$\left\{\begin{array}{rcl}A\mbox{e}^B&=&r_1\\ A\mbox{e}^{Bk}&=&r_k\end{array}\right.$$
% 
% The algorithm stops when both of the following conditions are satisfied:
%
% $$\left\{\begin{array}{rcl}A\mbox{e}^B&\leq&\varepsilon_1\\ AB\mbox{e}^{Bk}&\geq&-\varepsilon_2\end{array}\right.$$
%
% where $\varepsilon_1$  and $\varepsilon_2$ are the user defined parameters:
%
% <html><span class="string">'eps_1'</span> and <span class="string">'eps_2'</span> respectively.</html>
%
% <html><a id="plotfcn"></a></html>
%% Plot functions
% <html>
% The <tt>edsd</tt> function can accept a <span
% class="string">'plotfcn'</span> option. A function or a cell array of
% functions can be passed to the method. These methods should be defined as:
% </html>
%
%   function plotfcn(meta,iter)
%       ...
%   end
%
% where |meta| and |iter| are parameters passed to the function by |edsd|.
% |iter| is the last completed iteration and |meta| is the last trained
% |meta| (_i.e.,_ the one trained at the end of iteration |iter|). Each of
% these function is allocated a figure at the begining of |edsd| with:
%
%   hold on
%
% For example:
%
%   function plot_meta(meta,iter)
%       clf;
%       meta.isoplot;
%       title(['Iterations ' num2str(iter) ' completed'])
%   end
%
%% Parameters
% <html><table id="params" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'schedule'</span></td>
%     <td>(1 x 2) positive integer, { [2 1] }</td>
%     <td>Schedule used to mix "max-min" and "anti-locking" samples. The default schedule, [2 1], specifies the use of 2 "max-min" iterations followed by 1 "anti-locking" iteration.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'iter_max'</span></td>
%     <td>positive integer, {30}</td>
%     <td>Number of iterations</td>
%   </tr>
%   <tr>
%     <td><span class="string">'vectorized'</span></td>
%     <td>logical, {<tt>true</tt>}</td>
%     <td>Whether the function <tt>f</tt> is vectorized</td>
%   </tr>
%   <tr>
%     <td><span class="string">'f_Parallel'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>If <span class="string">'vectorized'</span> is set to <tt>false</tt>, whether new samples should be evaluated in parallel</td>
%   </tr>
%   <tr>
%     <td><span class="string">'extra_output'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Whether the function <tt>f</tt> is returning a second output that needs to be stored and returned (this extra output should be a cell row array)</td>
%   </tr>
%   <tr>
%     <td><span class="string">'conv'</span></td>
%     <td>logical, {<tt>true</tt>}</td>
%     <td>Should convergence be checked (<tt>true</tt>) or wait for <i>max_iter</i> (<tt>false</tt>) (see, <a href="#ref_bas2">Basudhar et al., 2008</a>)</td>
%   </tr>
%   <tr>
%     <td><span class="string">'plot_conv'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Should convergence be plotted (requires <span class="string">'conv'</span> to be <tt>true</tt>)</td>
%   </tr>
%   <tr>
%     <td><span class="string">'conv_coef'</span></td>
%     <td>{<span class="string">'fit'</span>} or <span class="string">'direct'</span></td>
%     <td>Method to compute coefficient of the exponential involved in the convergence</td>
%   </tr>
%   <tr>
%     <td><span class="string">'eps_1'</span></td>
%     <td>numeric, {4e-3}</td>
%     <td>Tolerance on class change ratio</td>
%   </tr>
%   <tr>
%     <td><span class="string">'eps_2'</span></td>
%     <td>numeric, {5e-4}</td>
%     <td>Tolerance on class change rate</td>
%   </tr>
%   <tr>
%     <td><span class="string">'x_conv'</span></td>
%     <td>numeric, {(1e4 x <tt>M.dim</tt>) LHS}</td>
%     <td>Convergence points</td>
%   </tr>
%   <tr>
%     <td><span class="string">'display_edsd'</span></td>
%     <td>logical, {<tt>true</tt>}</td>
%     <td>Display level</td>
%   </tr>
%   <tr>
%     <td><span class="string">'plotfcn'</span></td>
%     <td>cell or <tt>function_handle</tt>, { [ ] }</td>
%     <td>A function or a cell array of functions to be executed at the end of each iteration, see <a href=#plotfcn>Plot functions</a></td>
%   </tr>
% </table></html>
%
% In addition, options from <anti_lock.html |anti_lock|>, <mm.html |mm|>
% and <http://www.mathworks.com/help/gads/multistart-class.html
% |MultiStart|> can be used as well. 
%
%% Example
% Perform 5 iterations of EDSD and plot the SVM collection

DOE=CODES.sampling.cvt(20,2,'lb',[-5 -5],'ub',[5 5]);
svm=CODES.fit.svm(DOE,DOE(:,1)-DOE(:,2));
svm_col=CODES.sampling.edsd(@(x)(x(:,1)-x(:,2)),svm,[-5 -5],[5 5],'iter_max',5);
for i=1:5
    svm_col{i}.isoplot('new_fig',true,'lb',[-5 -5],'ub',[5 5])
    if i<5
        plot(svm_col{i+1}.X(end,1),svm_col{i+1}.X(end,2),'ms')
    end
end
axis square

%% Mini Tutorial
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table id="demo_table" border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_method_edsd.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_method_edsd.html">A mini tutorial of the capabilities of the <tt>edsd</tt> function.</a><br></td>
%         </tr>
%     </table>
% </html>
%
%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_bas2"><span style="color:#005fce;">Basudhar and Missoum
%   (2008)</span>: Basudhar A., Missoum S., (2008) <i>Adaptive explicit
%   decision functions for probabilistic design and optimization using
%   support vector machines</i>. Computers &amp; Structures
%   86(19):1904-1917 - <a
%   href="http://dx.doi.org/10.1007/s00158-010-0511-0">DOI</a></li> 
%   <li id="ref_bas"><span style="color:#005fce;">Basudhar and Missoum
%   (2010)</span>: Basudhar A., Missoum S., (2010) <i>An improved adaptive
%   sampling scheme for the construction of explicit boundaries</i>.
%   Structural and Multidisciplinary Optimization 42(4):517-529 - <a
%   href="http://dx.doi.org/10.1007/s00158-010-0511-0">DOI</a></li>
%   <li id="ref_bas1"><span style="color:#005fce;">Basudhar, 2011</span>:
%   Basudhar A., (2011) <i>Computational optimal design and uncertainty
%   quantification of complex systems using explicit decision
%   boundaries</i>. The University of Arizona - <a
%   href="http://dx.doi.org/10150/201491">DOI</a></li> 
%   <li id="ref_lac"><span style="color:#005fce;">Lacaze and Missoum
%   (2014)</span>: Lacaze S., Missoum S., (2014) <i>A generalized "max-min"
%   sample for surrogate update</i>. Structural and Multidisciplinary
%   Optimization 49(4):683-687 - <a
%   href="http://dx.doi.org/10.1007/s00158-013-1011-9">DOI</a></li> 
% </ul></html>
%
%% See also
% <anti_lock.html anti_lock> | <gmm.html gmm> | <mm.html mm>
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
