%% <CODES.html CODES> / <fit_main.html fit> / svm
% _Train a Support Vector Machine_
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
% * |svm=CODES.fit.svm(x,y)| builds an svm based on the training set
% |(x,y)|.
% * |svm=CODES.fit.svm(...,param,value)| uses a list of parameters
% |param| and values |value| (_c.f._, <#params parameter table>).
%
% <html><a id="description"></a></html>
%% Description
% Support Vector Machine (SVM) is a machine learning classification tool.
% Its core idea relies on the definition of an optimal decision function.
% In the linear case, the decision function is a hyper-plane which is
% defined through the following quadratic optimization problem:
%
% $$\begin{array}{rll}\mathop{\min}\limits_{\beta,b}&\frac{1}{2}||\beta||^2\\\textbf{s.t.}&1-l_i(\beta^T\mathbf{x}^{(i)}+b)\leq0&\forall i=\{1,\ldots,n\}\end{array}$$
%
% where $n$ is the number of training samples, and the optimal separating plane
% is defined as $\beta^T\mathbf{x}+b=0$. The constant $b$ (sometimes referred to as
% $\beta_0$) is called the bias, $\mathbf{x}^{(i)}$ is
% the $i\textrm{\textsuperscript{th}}$ training sample, and $l^{(i)}$ the $i\textrm{\textsuperscript{th}}$ label.  As
% per convention, labels $l^{(i)}$ derive from function values $y^{(i)}$
% such that:
%
% $$l^{(i)}=\left\{\begin{array}{ll}+1&\textrm{if }y^{(i)}>0\\-1&\textrm{if }y^{(i)}\leq0\end{array}\right.$$
% 
% Note: in the case of a response $f$, and a threshold $f_0$, the
% classification is performed on the sign of a limit state function $y$
% defined as $y(x)=f(x)-f_0$  or  $y(x)=f_0-f(x)$.
%
% In the case of non-separable data, the optimization problem is infeasible
% and needs to be relaxed. This is done through the introduction of slack
% variables $\xi_i$:
%
% $$\begin{array}{rll}\mathop{\min}\limits_{\beta,b,\xi}&\frac{1}{2}||\beta||^2+\frac{C}{L}\displaystyle\sum_{i=1}^n\xi_i^L\\\textbf{s.t.}&1-l_i(\beta^T\mathbf{x}^{(i)}+b)-\xi_i\leq0&\forall i=\{1,\ldots,n\}\\&\xi_i\geq0&\forall i=\{1,\ldots,n\}\end{array}$$
%
% where $L$ is either 1 or 2 and represents the loss function used. In the
% remainder of this help, $L=1$ (L1 SVM) is used but can be easily extended
% to L2 SVM. Using Karush-Kuhn-Tucker conditions, one can show that:
%
% $$\left\{\begin{array}{rcl}0&=&\displaystyle\sum_{i=1}^n\alpha_il^{(i)}\\\beta&=&\displaystyle\sum_{i=1}^n\alpha_il^{(i)}\mathbf{x}^{(i)}\\\alpha_i&=&C-\mu_i\end{array}\right.$$
%
% where $\alpha_i$ and $\mu_i$ are the $i\textrm{\textsuperscript{th}}$
% Lagrange multiplier associated to the first and second set of
% constraints,respectively. This leads to the dual problem:
%
% $$\begin{array}{rll}\mathop{\max}\limits_{\alpha}&\displaystyle\sum_{i=1}^n\alpha_i-\frac{1}{2}\displaystyle\sum_{i=1}^n\displaystyle\sum_{j=1}^n\alpha_i\alpha_jl^{(i)}l^{(j)}\mathbf{x}^{(i)T}\mathbf{x}^{(j)}\\\textbf{s.t.}&0\leq\alpha_i\leq C&\forall i=\{1,\ldots,n\}\\&\displaystyle\sum_{i=1}^n\alpha_il^{(i)}=0\end{array}$$
%
% Finally, the so-called kernel trick consists in recognizing that the
% scalar product $x^Ty$ could be replaced by a kernel function $K_\theta$
% of parameter $\theta$ such that the dual problem becomes:
%
% $$\begin{array}{rll}\mathop{\max}\limits_{\alpha}&\displaystyle\sum_{i=1}^n\alpha_i-\frac{1}{2}\displaystyle\sum_{i=1}^n\displaystyle\sum_{j=1}^n\alpha_i\alpha_jl^{(i)}l^{(j)}K_\theta(\mathbf{x}^{(i)},\mathbf{x}^{(j)})\\\textbf{s.t.}&0\leq\alpha_i\leq C&\forall i=\{1,\ldots,n\}\\&\displaystyle\sum_{i=1}^n\alpha_il^{(i)}=0\end{array}$$
%
% For an in-depth discussion of Support Vector Machine and Machine
% Learning, the interested reader is referred to <#ref_vap Vapnik (2000)>.
%
% Slack variables, bias, Lagrange multipliers, and indices of the support
% vectors can be obtained using: |svm.xis|, |svm.bias|, |svm.alphas|, and
% |svm.SVs|.
%
% <html><a id="kernels"></a></html>
%
% <html><h3>Kernels</h3></html>
%
% Two kernels are available:
%
% * Linear:
%
% $$K(x,y)=x^Ty$$
%
% * Gaussian:
%
% $$K_\theta(x,y)=\exp\left[\frac{||x-y||^2}{2\theta^2}\right]$$
%
% <html><a id="solvers"></a></html>
%
% <html><h3>Solvers</h3></html>
%
% Three solvers are implemented:
%
% * Primal (linear kernel only), uses |quadprog| to solve:
%
% $$\begin{array}{rll}\mathop{\min}\limits_{\beta,b,\xi}&\frac{1}{2}||\beta||^2+\frac{C}{L}\displaystyle\sum_{i=1}^n\xi_i^L\\\textbf{s.t.}&1-l_i(\beta^T\mathbf{x}^{(i)}+b)-\xi_i\leq0&\forall i=\{1,\ldots,n\}\\&\xi_i\geq0&\forall i=\{1,\ldots,n\}\end{array}$$
%
% Ideas to extend the primal solver can be found in <#ref_cha Chapelle
% (2007)>.
%
% * Dual, uses |quadprog| to solve:
% 
% $$\begin{array}{rll}\textrm{If }L=1\ :\ \mathop{\max}\limits_{\alpha}&\displaystyle\sum_{i=1}^n\alpha_i-\frac{1}{2}\displaystyle\sum_{i=1}^n\displaystyle\sum_{j=1}^n\alpha_i\alpha_jl^{(i)}l^{(j)}K_\theta(\mathbf{x}^{(i)},\mathbf{x}^{(j)})\\\textbf{s.t.}&0\leq\alpha_i\leq C&\forall i=\{1,\ldots,n\}\\&\displaystyle\sum_{i=1}^n\alpha_il^{(i)}=0\end{array}$$
%
% $$\begin{array}{rll}\textrm{If }L=2\ :\ \mathop{\max}\limits_{\alpha}&\displaystyle\sum_{i=1}^n\alpha_i-\frac{1}{2}\displaystyle\sum_{i=1}^n\displaystyle\sum_{j=1}^n\alpha_i\alpha_jl^{(i)}l^{(j)}\left(K_\theta(\mathbf{x}^{(i)},\mathbf{x}^{(j)})+\frac{\delta_{ij}}{C}\right)\\\textbf{s.t.}&0\leq\alpha_i&\forall i=\{1,\ldots,n\}\\&\displaystyle\sum_{i=1}^n\alpha_il^{(i)}=0\end{array}$$
%
% * libSVM, presented in <#ref_libsvm Chang and Lin (2011)> uses an
% extremly efficient SMO-type algorithm to solve the dual formulation.
%
% <html><a id="weights"></a></html>
%
% <html><h3>Weighted formulation</h3></html>
%
% <#ref_osuna Osuna et al. (1997)> and <#ref_vap Vapnik (2000)> introduced
% different cost coefficients (i.e., weights) for the different classes in
% the SVM formulation. The corresponding linear formulation is:
%
% $$\begin{array}{rl}\mathop{\min}\limits_{\mathbf{w},\mathbf{\xi},b}&\frac{1}{2} \|\mathbf{w}\|^2 + C^+ \sum_{i=1}^{N^+} \xi_i + C^- \sum_{i=1}^{N^-} \xi_i\\\textbf{s.t.}&y_i(\mathbf{w}\cdot \mathbf{x}_i - b) \ge 1 - \xi_i\\&\xi_i \ge 0 , i = 1,\dots,N\end{array}$$
%
% where $C^+$ and $C^-$ are cost coefficients for the +1 and -1 classes
% respectively. $N^+$ and $N^-$ are the number of samples from +1 and -1
% classes. The coefficients are typically chosen as <#ref_libsvm (Chang and
% Lin, 2011)>:
%
% $$\begin{array}{r}C^+ = C \times w^+\\C^- = C \times w^-\end{array}$
%
% where $C$ is the common cost coefficient for both classes, $w^+$ and
% $w^-$ are the weights for +1 and -1 class respectively. The weights are
% typically chosen as:
%
% $$w^+ = 1$$
%
% $$w^- = \frac{N^+}{N^-}$$
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
%     <td>Define scaling method for the inputs (<i>c.f.</i>, <a href=#scaling>Scaling</a> for details)</td>
%   </tr>
%   <tr>
%     <td><span class="string">'UseParallel'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Switch to use parallel settings</td>
%   </tr>
%   <tr>
%     <td><span class="string">'theta'</span></td>
%     <td>numeric, { [ ] }</td>
%     <td>Value for kernel parameter. If [ ], should be calibrated.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'kernel'</span></td>
%     <td>{<span class="string">'gauss'</span>}, <span class="string">'lin'</span></td>
%     <td>Kernel type, see <a href=#kernels>Kernels</a>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'solver'</span></td>
%     <td>{<span class="string">'libsvm'</span>}, <span class="string">'dual'</span>, <span class="string">'primal'</span></td>
%     <td>Type of solver to use to solve the SVM optimization problem, see <a href=#solvers>Solvers</a>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'loss'</span></td>
%     <td>{1}, 2</td>
%     <td>Loss function.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'C'</span></td>
%     <td>positive numeric, { [ ] }</td>
%     <td>Cost parameter. If [ ], should be calibrated.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'weight'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>If <tt>true</tt>, train weighted SVM, see <a href=#weights>Weighted formulation</a>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'w_plus'</span></td>
%     <td>numeric, {1}</td>
%     <td>Weight for +1 samples. If default and <span class="string">'weight'</span> is <tt>true</tt>, weight computed based on sample imbalance.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'w_minus'</span></td>
%     <td>numeric, {1}</td>
%     <td>Weight for -1 samples. If default and <span class="string">'weight'</span> is <tt>true</tt>, weight computed based on sample imbalance.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'param_select'</span></td>
%     <td><ul style="margin-bottom:0px;">
%       <li>{<span class="string">'fast'</span>}</li>
%       <li><span class="string">'loo'</span></li>
%       <li><span class="string">'cv'</span></li>
%       <li><span class="string">'chapelle'</span></li>
%       <li><span class="string">'Nsv'</span></li>
%       <li><span class="string">'loo_bal'</span></li>
%       <li><span class="string">'cv_bal'</span></li>
%       <li><span class="string">'chapelle_bal'</span></li>
%       <li><span class="string">'Nsv_bal'</span></li>
%       <li><span class="string">'auc'</span></li>
%       <li><span class="string">'cv_auc'</span></li>
%       <li><span class="string">'stiffest'</span></li>
%     </ul></td>
%     <td>Kernel parameter calibration strategy, see <a href=Test_fit_svm_param_select.html>svm (parameters selection)</a>. Kernel parameters are optimized such that they either minimize (maximize in the case of the AUC) the elected metric or satisfy some heuristic (<span class="string">'fast'</span> or <span class="string">'stiffest'</span>).</td>
%   </tr>
% </table></html>
%
% <html><a id="properties"></a></html>
%
% <html><a id="evaluation"></a></html>
%% Evaluation and Post-Processing
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table id="demo_table" border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="svm_method.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="svm_method.html">Capabilities of an <tt>svm</tt> object.</a><br></td>
%         </tr>
%     </table>
% </html>
%
% <html><a id="example"></a></html>
%% Mini tutorials
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table id="demo_table" border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_fit_svm.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_fit_svm.html">A mini tutorial of the capabilities of the <tt>svm</tt> class.</a><br></td>
%         </tr>
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_fit_svm_param_select.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_fit_svm_param_select.html">A presentation of parameters selection techniques for <tt>svm</tt>.</a><br></td>
%         </tr>
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_fit_svm_path.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_fit_svm_path.html">An illustration of the <tt>svm</tt> path.</a><br></td>
%         </tr>
%     </table>
% </html>
%
%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_osuna"><span style="color:#005fce;">Osuna et al.
%   (1997)</span>: Osuna E., Freund R., Girosi F., (1997) <i>Support vector
%   machines: Training and applications</i>.</li>
%   <li id="ref_vap"><span style="color:#005fce;">Vapnik (2000)</span>:
%   Vapnik V., (2000) <i>The nature of statistical learning theory</i>.
%   Springer</li> 
%   <li id="ref_cha"><span style="color:#005fce;">Chapelle (2007)</span>:
%   Chapelle O., (2010) <i>Training a support vector machine in the
%   primal</i>. Neural Computation, 19(5)1155-1178 - <a
%   href="http://dx.doi.org/10.1162/neco.2007.19.5.1155">DOI</a></li>
%   <li id="ref_libsvm"><span style="color:#005fce;">Chang and Lin
%   (2011)</span>: Chang C.C., Lin C.J., (2011) <i>LIBSVM : a library for
%   support vector machines.</i> ACM Transactions on Intelligent Systems
%   and Technology, 2(3):1-27. <a
%   href="http://www.csie.ntu.edu.tw/~cjlin/libsvm">Software</a></li>
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
