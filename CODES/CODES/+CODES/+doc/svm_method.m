%% <CODES.html CODES> / <fit_main.html fit> / svm (methods)
% _Methods of the class_ |svm|
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%%
% <html><a id="eval"></a></html>
%% eval
% Evaluate new samples |x|
%
% <html><h3>Syntax</h3></html>
%
% * |y_hat=svm.eval(x)| return the SVM values |y_hat| of the samples |x|
% * |[y_hat,grad]=svm.eval(x)| return the gradients |grad| at |x|
%
% <html><h3>Example</h3></html>
svm=CODES.fit.svm([1 1;20 2],[1;-1]);
[y_hat,grad]=svm.eval([10 0.5;5 0.6;14 0.8]);
disp([[' y_hat : ';'grad_1 : ';'grad_2 : '] num2str([y_hat';grad'],'%1.3f  ')])
%%
% <html><a id="class"></a></html>
%% class
% Provides the sign of input |y|, different than MATLAB
% sign function for |y=0|.
%
% <html><h3>Syntax</h3></html>
%
% * |lab=svm.class(y)| computes labels |lab| for function values |y|.
%
% <html><h3>Example</h3></html>
svm=CODES.fit.svm([1;2],[1;-1]);
y=[1;-1;-2;3;0];
lab=svm.class(y);
disp([['   y : ';' lab : ';'sign : '] num2str([y';lab';sign(y')],'%1.3f  ')])
%%
% <html><h3>See also</h3><a href=#eval_class>eval_class</a></html>
%
% <html><a id="eval_class"></a></html>
%% eval_class
% Evaluate class of new samples |x|
%
% <html><h3>Syntax</h3></html>
%
% * |lab=svm.eval_class(x)| computes the labels |lab| of the input samples
% |x|.
% * |[lab,y_hat]|=svm.eval_class(x) also returns predicted function values
% |y_hat|.
%
% <html><h3>Example</h3></html>
svm=CODES.fit.svm([1;2],[1;-1]);
x=[0;1;2;3];
[lab,y_hat]=svm.eval_class(x);
disp([['y_hat : ';'  lab : '] num2str([y_hat';lab'],'%1.3f  ')])
%%
% <html><h3>See also</h3><a href=#class>class</a></html>
%
% <html><a id="scale"></a></html>
%% scale
% Perform scaling of samples |x_unsc|
%
% <html><h3>Syntax</h3></html>
%
% * |x_sc=svm.scale(x_unsc)| scales |x_unsc|.
%
% <html><h3>Example</h3></html>
svm=CODES.fit.svm([1 1;20 2],[1;-1]);
x_unsc=[1 1;10 1.5;20 2];
x_sc=svm.scale(x_unsc);
disp('        Unscaled             Scaled')
disp([x_unsc x_sc])
%%
% <html><h3>See also</h3><a href=#unscale>unscale</a></html>
%
% <html><a id="unscale"></a></html>
%% unscale
% Perform unscaling of samples |x_sc|
%
% <html><h3>Syntax</h3></html>
%
% * |x_unsc=svm.unscale(x_sc)| unscales |x_sc|.
%
% <html><h3>Example</h3></html>
svm=CODES.fit.svm([1 1;20 2],[1;-1]);
x_sc=[0 0;0.4737 -1;1 1];
x_unsc=svm.unscale(x_sc);
disp('         Scaled             Unscaled')
disp([x_sc x_unsc])
%%
% <html><h3>See also</h3><a href=#scale>scale</a></html>
%
% <html><a id="add"></a></html>
%% add
% Retrain |svm| after adding a new sample |(x,y)|
%
% <html><h3>Syntax</h3></html>
%
% * |svm=svm.add(x,y)| adds a new sample |x| with function value |y|.
%
% <html><h3>Example</h3></html>
svm=CODES.fit.svm([1;2],[1;-1]);
disp(['Predicted class at x=1.4, ' num2str(svm.eval_class(1.4))])
svm=svm.add(1.5,-1);
disp(['Updated predicted class at x=1.4, ' num2str(svm.eval_class(1.4))])
%%
% <html><a id="me"></a></html>
%% me
% Compute the Misclassification Error (ME) for |(x,y)| (%)
%
% <html><h3>Syntax</h3></html>
%
% * |stat=svm.me(x,y)| compute the me for |(x,y)|
% * |stat=svm.me(x,y,use_balanced)| returns Balanced Misclassification
% Error (BME) if use_balanced is set to true
%
% <html><h3>Description</h3></html>
%
% For a representative (sample,label) $(\mathbf{x},\mathbf{y})$ of the
% domain of interest and predicted labels $\tilde{\mathbf{y}}$, the
% classification error is defined as:
%
% $$err_{class}=\frac{1}{n}\sum_{i=1}^n\mathcal{I}_{y^{(i)}\neq\tilde{y}^{(i)}}$$
%
% On the other hand, the balanced classification error is defined as:
%
% $$err_{class}^{bal}=\frac{1}{n}\sum_{i=1}^n\left[w_p\mathcal{I}_{y^{(i)}=+1}\mathcal{I}_{y^{(i)}\neq\tilde{y}^{(i)}}+w_m\mathcal{I}_{y^{(i)}=-1}\mathcal{I}_{y^{(i)}\neq\tilde{y}^{(i)}}\right]$$
%
% where $w_p$ and $w_m$ are weights computed based on training samples such
% that:
%
% $$w_p=\frac{n}{2n_+}\quad;\quad w_m=\frac{n}{2n_-}$$
%
% where $n$ is the total number of samples and $n_+$ (resp. $n_-$) is the
% total number of positive (resp. negative) samples. This weights satisfy a
% set of condition:
%
% * $err_{class}^{bal}=0.5$ if all positive or all negative samples are
% misclassified;
% * $err_{class}^{bal}=0$ if all samples are properly classified;
% * $err_{class}^{bal}=1$ if all samples are misclassified;
% * $w_p=w_m=1\textrm{ if }n_+=n_-=\frac{n}{2}\quad\Rightarrow\quad err_{class}^{bal}=err_{class}$.
%
% This function is typically used to validate meta-models on an independent
% validation set as in <#ref_peng Jiang and Missoum (2014)>.
%
% <html><h3>Example</h3></html>
f=@(x)x-4;
x=[2;8];y=f(x);
svm=CODES.fit.svm(x,y);
x_t=linspace(0,10,1e4)';y_t=f(x_t);
err=svm.me(x_t,y_t);
bal_err=svm.me(x_t,y_t,true);
disp('On evenly balanced training set, standard and balanced prediction error return same values')
disp([err bal_err])
x=[2;5;8];y=f(x);
svm=CODES.fit.svm(x,y);
err=svm.me(x_t,y_t);
bal_err=svm.me(x_t,y_t,true);
disp('On unevenly balanced training set, standard and balanced prediction error return different values')
disp([err bal_err])

%%
% <html><h3>See also</h3><a href=#auc>auc</a> | <a href=#mse>mse</a> | <a
% href=#rmse>rmse</a> | <a href=#cv>cv</a> | <a href=#loo>loo</a></html>
%
% <html><a id="auc"></a></html>
%% auc
% Returns the Area Under the Curve (AUC) for (x,y) (%)
%
% <html><h3>Syntax</h3></html>
%
% * |stat=CODES.fit.svm.auc(x,y)| return the AUC |stat| for the samples
% |(x,y)|
% * |stat=CODES.fit.svm.auc(x,y,ROC)| plot the ROC curves if |ROC|is set
% to |true|
% * |[stat,FP,TP]=CODES.fit.svm.auc(...)| returns the false positive rate
% |FP| and the true positive rate |TP|
%
% <html><h3>Description</h3></html>
%
% A receiver operating characteristic (ROC) curve <#ref_metz Metz (1978)>
% is a graphical representation of the relation between true and false
% positive predictions for a binary classifier. It uses all possible
% decision thresholds from the prediction. In the case of SVM
% classification, thresholds are defined by the SVM values. More
% specifically, for each threshold a True Positive Rate:
%
% $$TPR=\frac{TP}{TP+FN}$$
%
% and a False Positive Rate:
%
% $$FPR=\frac{FP}{FP+TN}$$
%
% are calculated. $TP$ and $TN$ are the number of true positive and true
% negative predictions while $FP$ and $FN$ are the number of false positive
% and false negative predictions, respectively. The ROC curve represents
% $TPR$ as a function of $FPR$.
%
% Once the ROC curve is constructed, the area under the ROC curve (AUC) can
% be calculated and used as a validation metric. A perfect classifier will
% have an AUC equal to one. An AUC value of 0.5 indicates no discriminative
% ability.
%
% <html><img src='rocexample.png' width=500></html>
%
% <html><h3>Example</h3></html>
f=@(x)x(:,2)-sin(10*x(:,1))/4-0.5;
x=CODES.sampling.cvt(30,2);y=f(x);
svm=CODES.fit.svm(x,y);
auc_val=svm.auc(svm.X,svm.Y);
x_t=rand(1000,2);
y_t=f(x_t);
auc_new=svm.auc(x_t,y_t);
disp(['AUC value over training set : ' num2str(auc_val,'%7.3f')])
disp([' AUC value over testing set : ' num2str(auc_new,'%7.3f')])
%%
% <html><h3>See also</h3><a href=#me>me</a> | <a
% href=#mse>mse</a> | <a href=#rmse>rmse</a> | <a href=#cv>cv</a></html>
%%
% <html><a id="N_sv_ratio"></a></html>
%% N_sv_ratio
% Returns the support vector ratio as a percent
%
% <html><h3>Syntax</h3></html>
%
% * |stat=svm.N_sv_ratio| return the support vector ratio |stat|
% * |stat=svm.N_sv_ratio(use_balanced)| returns the balanced support vector
% ratio if |use_balanced| is set to |true|
%
% <html><h3>Description</h3></html>
%
% The ratio of support vectors is defined as:
%
% $$N_{sv}=\frac{n^{sv}}{n}$$
%
% where $n_{sv}$ is the number of support vectors. On the other hand, the
% balanced support vector ratio is defined as: 
%
% $$N_{sv}^{bal}=\frac{w_pn_+^{sv}+w_mn_-^{sv}}{n}$$
%
% where $n_+^{sv}$ and $n_-^{sv}$ are the number of positive and
% negative support vectors, respectively. $w_p$ and $w_m$ are weights 
% computed based on training samples such that:
%
% $$w_p=\frac{n}{2n_+}\quad;\quad w_m=\frac{n}{2n_-}$$
%
% where $n$ is the total number of samples and $n_+$ (resp. $n_-$) is the
% total number of positive (resp. negative) samples. This weights satisfy a
% set of conditions:
%
% * $N_{sv}^{bal}=0.5$ if all positive or all negative samples are
% support vectors;
% * $N_{sv}^{bal}=0$ if no samples are support vectors;
% * $N_{sv}^{bal}=1$ if all samples are support vectors;
% * $w_p=w_m=1\textrm{ if }n_+=n_-=\frac{n}{2}\quad\Rightarrow\quad N_{sv}^{bal}=N_{sv}$.
%
% <html><h3>Example</h3></html>
f=@(x)x-4;
x=[2;8];y=f(x);
svm=CODES.fit.svm(x,y);
Nsv=svm.N_sv_ratio;
bal_Nsv=svm.N_sv_ratio(true);
disp('On an evenly balanced training set, standard and balanced support vector ratios return the same value')
disp([Nsv bal_Nsv])
x=[2;5;8];y=f(x);
svm=CODES.fit.svm(x,y);
Nsv=svm.N_sv_ratio;
bal_Nsv=svm.N_sv_ratio(true);
disp('On an unevenly balanced training set, standard and balanced support vector ratios each return a different value')
disp([Nsv bal_Nsv])
%%
% <html><h3>See also</h3><a href=#loo>loo</a> | <a
% href=#cv>cv</a> | <a href=#chapelle>chapelle</a> | <a
% href=#auc>auc</a></html>
%
% <html><a id="chapelle"></a></html>
%% chapelle
% Returns Chapelle estimate of the LOO error as a percentage
%
% <html><h3>Syntax</h3></html>
%
% * |stat=svm.chapelle| returns the Chapelle estimate of the LOO error
% |stat|
% * |stat=svm.chapelle(use_balanced)| returns the Chapelle estimate of the
% balanced LOO error if |use_balanced| is set to |true|
%
% <html><h3>Description</h3></html>
%
% This function computes LOO error estimates as derived in <#ref_cha Chapelle et al.,
% 2002>. Weight used when |use_balanced| is |true| are described in <#loo
% loo>. 
%
% <html><h3>Example</h3></html>
f=@(x)x(:,1)-0.5;
x=CODES.sampling.cvt(30,2);y=f(x);
svm=CODES.fit.svm(x,y);
chap_err=svm.chapelle;
bal_chap_err=svm.chapelle(true);
disp('On an evenly balanced training set, standard and balanced Chapelle errors return the same value')
disp([chap_err bal_chap_err])
x=CODES.sampling.cvt(31,2);y=f(x);
svm=CODES.fit.svm(x,y);
chap_err=svm.chapelle;
bal_chap_err=svm.chapelle(true);
disp('On an unevenly balanced training set, standard and balanced Chapelle errors each return a different value')
disp([chap_err bal_chap_err])
%%
% <html><h3>See also</h3><a href=#N_sv_ratio>N_sv_ratio</a> | <a
% href=#loo>loo</a> | <a href=l#cv>cv</a> |
% <a href=#auc>auc</a></html>
%%
% <html><a id="loo"></a></html>
%% loo
% Returns the Leave One Out (LOO) error (%)
%
% <html><h3>Syntax</h3></html>
%
% * |stat=svm.loo| return the loo error |stat|
% * |stat=svm.loo(param,value)| use set of parameters |param| and values
% |value| (_c.f._, <#params_loo parameter table>)
%
% <html><h3>Description</h3></html>
%
% Define $\tilde{l}^{(i)}$ the $i\textrm{\textsuperscript{th}}$ predicted
% label and $\tilde{l}_{-j}^{(i)}$ the $i\textrm{\textsuperscript{th}}$
% predicted label using the SVM trained without the
% $j\textrm{\textsuperscript{th}}$ sample. The Leave One Out (LOO) error is
% defined as:
%
% $$err_{loo}=\frac{1}{n}\sum_{i=1}^n\mathcal{I}_{\tilde{l}^{(i)}\neq\tilde{l}_{-i}^{(i)}}$$
%
% On the other hand, the balanced LOO error is defined as: 
%
% $$err_{loo}^{bal}=\frac{1}{n}\sum_{i=1}^n\left[w_p\mathcal{I}_{l^{(i)}=+1}\mathcal{I}_{\tilde{l}^{(i)}\neq\tilde{l}_{-i}^{(i)}}+w_m\mathcal{I}_{l^{(i)}=-1}\mathcal{I}_{\tilde{l}^{(i)}\neq\tilde{l}_{-i}^{(i)}}\right]$$
%
% $w_p$ and $w_m$ are weights computed based on
% training samples such that:
%
% $$w_p=\frac{n}{2n_+}\quad;\quad w_m=\frac{n}{2n_-}$$
%
% where $n$ is the total number of samples and $n_+$ (resp. $n_-$) is the
% total number of positive (resp. negative) samples. This weights satisfy a
% set of condition:
%
% * $err_{loo}^{bal}=0.5$ if all positive or all negative samples are
% misclassified;
% * $err_{loo}^{bal}=0$ if no samples are misclassified;
% * $err_{loo}^{bal}=1$ if all samples are miscalssified;
% * $w_p=w_m=1\textrm{ if }n_+=n_-=\frac{n}{2}\quad\Rightarrow\quad err_{loo}^{bal}=err_{loo}$.
%
% <html><h3>Parameters</h3>
% <table id="params_loo" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'use_balanced'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Only for Misclassification Error, uses Balanced Misclassification Error if <tt> true></tt></td>
%   </tr>
%   <tr>
%     <td><span class="string">'metric'</span></td>
%     <td>{<span class="string">'me'</span>}, <span class="string">'mse'</span></td>
%     <td>Metric on which LOO procedure is applied, Misclassification Error (<span class="string">'me'</span>) or Mean Square Error (<span class="string">'mse'</span>)</td>
%   </tr>
% </table></html>
%
% <html><h3>Example</h3></html>
f=@(x)x(:,2)-sin(10*x(:,1))/4-0.5;
x=CODES.sampling.cvt(6,2);y=f(x);
svm=CODES.fit.svm(x,y);
loo_err=svm.loo;
bal_loo_err=svm.loo('use_balanced',true);
disp('On evenly balanced training set, standard and balanced loo error return same values')
disp([loo_err bal_loo_err])
x=CODES.sampling.cvt(5,2);y=f(x);
svm=CODES.fit.svm(x,y);
loo_err=svm.loo;
bal_loo_err=svm.loo('use_balanced',true);
disp('On unevenly balanced training set, standard and balanced loo error return different values')
disp([loo_err bal_loo_err])
%%
% <html><h3>See also</h3><a href=#cv>cv</a> | <a href=#auc>auc</a> | <a
% href=#me>me</a> | <a href=#mse>mse</a></html>
%
% <html><a id="cv"></a></html>
%% cv
% Returns the Cross Validation (CV) error over 10 folds (%)
%
% <html><h3>Syntax</h3></html>
%
% * |stat=svm.cv| return the cv error |stat|
% * |stat=svm.cv(param,value)| use set of parameters |param| and values
% |value| (_c.f._, <#params_cv parameter table>)
%
% <html><h3>Description</h3></html>
%
% This function follow the same outline as the <#loo |loo|> but uses a 10
% fold CV procedure instead of an $n$ fold one. Therefore, the |cv| and
% |loo| are the same for $n\leq10$ and |cv| returns an estimate of |loo|
% that is faster to compute for $n>10$.
%
% <html><h3>Parameters</h3>
% <table id="params_cv" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'use_balanced'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Only for Misclassification Error, uses Balanced Misclassification Error if <tt> true></tt></td>
%   </tr>
%   <tr>
%     <td><span class="string">'metric'</span></td>
%     <td><span class="string">'auc'</span>, {<span class="string">'me'</span>}, <span class="string">'mse'</span></td>
%     <td>Metric on which CV procedure is applied: Area Under the Curve (<span class="string">'auc'</span>), Misclassification Error (<span class="string">'me'</span>) or Mean Square Error (<span class="string">'mse'</span>)</td>
%   </tr>
% </table></html>
%
% <html><h3>Example</h3></html>
f=@(x)x(:,1)-0.5;
x=CODES.sampling.cvt(30,2);y=f(x);
svm=CODES.fit.svm(x,y);
rng(0); % To ensure same CV folds
cv_err=svm.cv;
rng(0);
bal_cv_err=svm.cv('use_balanced',true);
disp('On evenly balanced training set, standard and balanced cv error return same values')
disp([cv_err bal_cv_err])
x=CODES.sampling.cvt(31,2);y=f(x);
svm=CODES.fit.svm(x,y);
rng(0);
cv_err=svm.cv;
rng(0);
bal_cv_err=svm.cv('use_balanced',true);
disp('On unevenly balanced training set, standard and balanced cv error return different values')
disp([cv_err bal_cv_err])
%%
% <html><h3>See also</h3><a href=#loo>loo</a> | <a href=#auc>auc</a> | <a
% href=#me>me</a> | <a href=#mse>mse</a></html>
%
% <html><a id="class_change"></a></html>
%% class_change
% Compute the change of class between two meta-models over a sample |x| (%)
%
% <html><h3>Syntax</h3></html>
%
% * |stat=svm.class_change(svm_old,x)| compute the change of class of the
% sample |x| from meta-model |svm_old| to meta-model |svm| 
%
% <html><h3>Description</h3></html>
%
% This metric was used in <#ref_bas Basudhar and Missoum (2008)> as
% convergence metric and is defined as:
%
% $$class_{change}=\frac{1}{n_c}\sum_{i=1}^{n_c}\mathcal{I}_{\hat{y}_c^{(i)}\neq\tilde{y}_c^{(i)}}$$
%
% where $n_c$ is the number of convergence samples and $\hat{y}_c^{(i)}$
% (resp. $\tilde{y}_c^{(i)}$) is the $i\textrm{\textsuperscript{th}}$
% convergence predicted label using |svm_old| (resp. |svm|).
%
% <html><h3>Example</h3></html>
f=@(x)x-4;
x=[2;8];y=f(x);
svm=CODES.fit.svm(x,y);
x_t=linspace(0,10,1e4)';y_t=f(x_t);
err=svm.me(x_t,y_t);
svm_new=svm.add(5,f(5));
err_new=svm_new.me(x_t,y_t);
class_change=svm_new.class_change(svm,x_t);
disp(['Absolute change in prediction error : ' num2str(abs(err_new-err))])
disp(['Class change : ' num2str(class_change)])
%%
% <html><a id="plot"></a></html>
%% plot
% Display the meta-model |svm|
%
% <html><h3>Syntax</h3></html>
%
% * |svm.plot| plot the meta-model |svm|
% * |svm.plot(param,value)| use set of parameters |param| and values
% |value| (_c.f._, <#params_plot parameter table>)
% * |h=svm.plot(...)| returns graphical handles
%
% <html><h3>Parameters</h3>
% <table id="params_plot" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'new_fig'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Create a new figure</td>
%   </tr>
%   <tr>
%     <td><span class="string">'lb'</span></td>
%     <td>numeric, {<tt>svm.lb_x</tt>}</td>
%     <td>Lower bound of plot</td>
%   </tr>
%   <tr>
%     <td><span class="string">'ub'</span></td>
%     <td>numeric, {<tt>svm.ub_x</tt>}</td>
%     <td>Upper bound of plot</td>
%   </tr>
%   <tr>
%     <td><span class="string">'samples'</span></td>
%     <td>logical, {<tt>true</tt>}</td>
%     <td>Plot training samples</td>
%   </tr>
%   <tr>
%     <td><span class="string">'lsty'</span></td>
%     <td>string, {<span class="string">'k-'</span>}</td>
%     <td>Line style (1D), see also <a href="http://www.mathworks.com/help/matlab/ref/linespec.html">LineSpec</a></td>
%   </tr>
%   <tr>
%     <td><span class="string">'psty'</span></td>
%     <td>string, {<span class="string">'ko'</span>}</td>
%     <td>Samples style, see also <a href="http://www.mathworks.com/help/matlab/ref/linespec.html">LineSpec</a></td>
%   </tr>
%   <tr>
%     <td><span class="string">'legend'</span></td>
%     <td>logical, {<tt>true</tt>}</td>
%     <td>Add legend</td>
%   </tr>
% </table></html>
%
% <html><h3>Example</h3></html>
f=@(x)x-4;
x=[2;8];y=f(x);
svm=CODES.fit.svm(x,y);
svm.plot('new_fig',true)
%%
% <html><h3>See also</h3><a href=#isoplot>isoplot</a></html>
%
% <html><a id="isoplot"></a></html>
%% isoplot
% Display the 0 isocontour of the SVM |svm|
%
% <html><h3>Syntax</h3></html>
%
% * |svm.isoplot| plots the 0 isocontour of the meta-model |svm|
% * |svm.isoplot(param,value)| uses set of parameters |param| and values
% |value| (see <#params_isoplot parameter table>)
% * |h=svm.isoplot(...)| returns graphical handles
%
% <html><h3>Parameters</h3>
% <table id="params_isoplot" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'new_fig'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Create a new figure.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'th'</span></td>
%     <td>numeric, {<tt>0</tt>}</td>
%     <td>Isovalue to plot.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'lb'</span></td>
%     <td>numeric, {<tt>svm.lb_x</tt>}</td>
%     <td>Lower bound of plot.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'ub'</span></td>
%     <td>numeric, {<tt>svm.ub_x</tt>}</td>
%     <td>Upper bound of plot.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'samples'</span></td>
%     <td>logical, {<tt>true</tt>}</td>
%     <td>Plot training samples.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'mlsty'</span></td>
%     <td>string, {<span class="string">'r-'</span>}</td>
%     <td>Line style for -1 domain (1D), see also <a href="http://www.mathworks.com/help/matlab/ref/linespec.html">LineSpec</a>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'plsty'</span></td>
%     <td>string, {<span class="string">'b-'</span>}</td>
%     <td>Line style for +1 domain (1D), see also <a href="http://www.mathworks.com/help/matlab/ref/linespec.html">LineSpec</a>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'bcol'</span></td>
%     <td>string, {<span class="string">'k'</span>}</td>
%     <td>Boundary color, see also <a href="http://www.mathworks.com/help/matlab/ref/linespec.html">LineSpec</a>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'mpsty'</span></td>
%     <td>string, {<span class="string">'ro'</span>}</td>
%     <td>-1 samples style, see also <a href="http://www.mathworks.com/help/matlab/ref/linespec.html">LineSpec</a>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'ppsty'</span></td>
%     <td>string, {<span class="string">'bo'</span>}</td>
%     <td>+1 samples style, see also <a href="http://www.mathworks.com/help/matlab/ref/linespec.html">LineSpec</a>.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'use_light'</span></td>
%     <td>logical, {<tt>true</tt>}</td>
%     <td>Use light (3D).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'prev_leg'</span></td>
%     <td>cell, { {} }</td>
%     <td>Previous legend entry.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'legend'</span></td>
%     <td>logical, {<tt>true</tt>}</td>
%     <td>Add legend.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'sv'</span></td>
%     <td>logical, {<tt>true</tt>}</td>
%     <td>Plot support vectors</td>
%   </tr>
%   <tr>
%     <td><span class="string">'msvsty'</span></td>
%     <td>string, {<span class="string">'r+'</span>}</td>
%     <td>-1 samples style</td>
%   </tr>
%   <tr>
%     <td><span class="string">'psvsty'</span></td>
%     <td>string, {<span class="string">'b+'</span>}</td>
%     <td>+1 samples style</td>
%   </tr>
% </table></html>
%
% <html><h3>Example</h3></html>
f=@(x)x(:,2)-sin(10*x(:,1))/4-0.5;
x=CODES.sampling.cvt(6,2);y=f(x);
svm=CODES.fit.svm(x,y);
svm.isoplot('new_fig',true,'lb',[0 0],'ub',[1 1],'sv',false)
%%
% <html><a id="point_dist"></a></html>
%% point_dist
% <html>Returns the minimum, maximum, and mean values of the pairwise
% distances between +1 and -1 training samples of <tt>svm</tt> in the scaled
% domain. The mean value is used for <span
% class="string">'param_select'</span> set to <span
% class="string">'fast'</span> and as initial guess for other selection
% strategies.</html>
%
% <html><h3>Syntax</h3></html>
%
% * |[lb,ub,mean_dist]=svm.point_dist|
%
% <html><h3>Example</h3></html>
f=@(x)x(:,1)-0.5;
X=CODES.sampling.cvt(20,2);Y=f(X);
svm=CODES.fit.svm(X,Y,'param_select','fast');
[lb,ub,mean_dist]=svm.point_dist;
disp(['SVM theta value : ' num2str(svm.theta,'%1.3f  ')])
disp(['  Mean distance : ' num2str(mean_dist,'%1.3f  ')])
%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_bas"><span style="color:#005fce;">Basudhar et al.
%   (2008)</span>: Basudhar A., Missoum S., (2008) <i>Adaptive explicit
%   decision functions for probabilistic design and optimization using
%   support vector machines</i>. Computers &amp; Structures
%   86(19):1904-1917 - <a
%   href="http://dx.doi.org/10.1016/j.compstruc.2008.02.008">DOI</a></li>
%   <li id="ref_cha"><span style="color:#005fce;">Chapelle et al.
%   (2002)</span>: Chapelle, O., Vapnik, V., Bousquet, O., & Mukherjee, S.,
%   (2002) <i>Choosing multiple parameters for support vector machines</i>.
%   Machine Learning 46(1-3):131-159 - <a 
%   href="http://dx.doi.org/10.1023/A:1012450327387">DOI</a></li>
%   <li id="ref_peng"><span style="color:#005fce;">Jiang et al.
%   (2014)</span>: Jiang P., Missoum S., (2014) <i>Optimal SVM parameter
%   selection for non-separable and unbalanced datasets</i>. Structural and
%   Multidisciplinary Optimization 50(4):523-535 - <a 
%   href="http://dx.doi.org/10.1007/s00158-014-1105-z">DOI</a></li>
%   <li id="ref_metz"><span style="color:#005fce;">Metz (1978)</span>: Metz
%   C. E., (2008) <i>Basic principles of ROC analysis</i>. Seminars in
%   nuclear medicine 8(4):283-298 - <a
%   href="http://dx.doi.org/10.1016/S0001-2998(78)80014-2">DOI</a></li>
% </ul></html>
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
