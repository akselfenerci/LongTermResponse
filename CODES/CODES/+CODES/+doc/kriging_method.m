%% <CODES.html CODES> / <fit_main.html fit> / kriging (methods)
% _Methods of the class_ |kriging|
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
% Evaluate mean prediction of new samples |x|
%
% <html><h3>Syntax</h3></html>
%
% * |y_hat=kr.eval(x)| return the Kriging values |y_hat| of the samples
% |x|.
% * |[y_hat,grad]=kr.eval(x)| return the gradients |grad| at |x|.
%
% <html><h3>Example</h3></html>
kr=CODES.fit.kriging([1 1;20 2],[2;-1]);
[y_hat,grad]=kr.eval([10 0.5;5 0.6;14 0.8]);
CODES.common.disp_matrix([y_hat grad],[],{'Y','grad1','grad2'})
%%
% <html><h3>See also</h3><a href=#eval_var>eval_var</a> <a
% href=#eval_all>eval_all</a> <a href=#p_pos>P_pos</a></html>
%
% <html><a id="eval_var"></a></html>
%% eval_var
% Evaluate predicted variance at new samples |x|
%
% <html><h3>Syntax</h3></html>
%
% * |var_hat=kr.eval_var(x)| return the Kriging variance |var_hat| of the
% samples |x|.
% * |[var_hat,grad]=kr.eval_var(x)| return the gradients |grad| at |x|.
%
% <html><h3>Example</h3></html>
kr=CODES.fit.kriging([1 1;20 2],[2;-1]);
[y_hat,grad]=kr.eval_var([10 0.5;5 0.6;14 0.8]);
CODES.common.disp_matrix([y_hat grad],[],{'Y','grad1','grad2'})
%%
% <html><h3>See also</h3><a href=#eval>eval</a> <a
% href=#eval_all>eval_all</a> <a href=#p_pos>P_pos</a></html>
%
% <html><a id="eval_all"></a></html>
%% eval_all
% Evaluate predicted mean and variance at new samples |x|
%
% <html><h3>Syntax</h3></html>
%
% * |y_hat=kr.eval_var(x)| return the Kriging variance |var_hat| of the
% samples |x|.
% * |[y_hat,var_hat]=kr.eval_var(x)| return the Kriging variance |var_hat|
% of the samples |x|.
% * |[y_hat,var_hat,grad_y]=kr.eval_var(x)| return the gradients of the
% mean |grad_y| at |x|.
% * |[y_hat,var_hat,grad_y,grad_var]=kr.eval_var(x)| return the gradients
% of the variance |grad_var| at |x|.
%
% <html><h3>Example</h3></html>
kr=CODES.fit.kriging([1 1;20 2],[2;-1]);
[y_hat,var_hat,grad_y,grad_var]=kr.eval_all([10 0.5;5 0.6;14 0.8]);
CODES.common.disp_matrix([y_hat var_hat grad_y grad_var],[],...
    {'Y','Var','Y_grad1','Y_grad2','Var_grad1','Var_grad2'})
%%
% <html><h3>See also</h3><a href=#eval>eval</a> <a
% href=#eval_var>eval_var</a> <a href=#p_pos>P_pos</a></html>
%
% <html><a id="p_pos"></a></html>
%% P_pos
% Compute the probability of the kriging prediction to be higher than a
% threshold.
%
% <html><h3>Syntax</h3></html>
%
% * |p=kr.eval_var(x)| return the probability |p| of the samples |x| to be
% higher than 0.
% * |p=kr.eval_var(x,th)| return the probability |p| of the samples |x| to
% be higher than |th|.
% * |[p,grad]=kr.eval_var(...)| return the gradient |grad| of probability
% |p|.
%
% <html><h3>Example</h3></html>
kr=CODES.fit.kriging([1 1;20 2],[2;-1]);
[p,grad]=kr.P_pos([10 0.5;5 0.6;14 0.8],0.25);
CODES.common.disp_matrix([p grad],[],{'p','grad1','grad2'})
%%
% <html><a id="class"></a></html>
%% class
% Provides the sign of input |y|, different than MATLAB
% sign function for |y=0|.
%
% <html><h3>Syntax</h3></html>
%
% * |lab=kr.class(y)| computes labels |lab| for function values |y|.
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
% * |lab=kr.eval_class(x)| computes the labels |lab| of the input samples
% |x|.
% * |[lab,y_hat]|=kr.eval_class(x) also returns predicted function values
% |y_hat|.
%
% <html><h3>Example</h3></html>
kr=CODES.fit.kriging([1;2],[1;-1]);
x=[0;1;2;3];
[lab,y_hat]=kr.eval_class(x);
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
% * |x_sc=kr.scale(x_unsc)| scales |x_unsc|.
%
% <html><h3>Example</h3></html>
kr=CODES.fit.kriging([1 1;20 2],[1;-1]);
x_unsc=[1 1;10 1.5;20 2];
x_sc=kr.scale(x_unsc);
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
% * |x_unsc=kr.unscale(x_sc)| unscales |x_sc|.
%
% <html><h3>Example</h3></html>
kr=CODES.fit.kriging([1 1;20 2],[1;-1]);
x_sc=[0 0;0.4737 -1;1 1];
x_unsc=kr.unscale(x_sc);
disp('         Scaled             Unscaled')
disp([x_sc x_unsc])
%%
% <html><h3>See also</h3><a href=#scale>scale</a></html>
%
% <html><a id="scale_y"></a></html>
%% scale_y
% Perform scaling of function values |y_unsc|
%
% <html><h3>Syntax</h3></html>
%
% * |y_sc=kr.scale_y(y_unsc)| scales |y_unsc|.
%
% <html><h3>Example</h3></html>
kr=CODES.fit.kriging([1 1;20 2],[1;-3]);
y_unsc=[0.5;1;2];
y_sc=kr.scale_y(y_unsc);
CODES.common.disp_matrix([y_unsc y_sc],[],{'Unscaled','Scaled'})
%%
% <html><h3>See also</h3><a href=#unscale_y>unscale_y</a></html>
%
% <html><a id="unscale_y"></a></html>
%% unscale_y
% Perform unscaling of function values |y_sc|
%
% <html><h3>Syntax</h3></html>
%
% * |y_unsc=kr.unscale_y(y_sc)| unscales |y_sc|.
%
% <html><h3>Example</h3></html>
kr=CODES.fit.kriging([1 1;20 2],[1;-1]);
y_sc=[0;0.25;0.75];
y_unsc=kr.unscale_y(y_sc);
CODES.common.disp_matrix([y_unsc y_sc],[],{'Unscaled','Scaled'})
%%
% <html><h3>See also</h3><a href=#scale>scale</a></html>
%%
% <html><a id="add"></a></html>
%% add
% Retrain |kr| after adding a new sample |(x,y)|
%
% <html><h3>Syntax</h3></html>
%
% * |kr=kr.add(x,y)| adds a new sample |x| with function value |y|.
%
% <html><h3>Example</h3></html>
kr=CODES.fit.kriging([1;2],[1;-1]);
disp(['Predicted class at x=1.4, ' num2str(kr.eval_class(1.4))])
kr=kr.add(1.5,-1);
disp(['Updated predicted class at x=1.4, ' num2str(kr.eval_class(1.4))])
%%
% <html><a id="mse"></a></html>
%% mse
% Compute the Mean Square Error (MSE) for |(x,y)| (not for classification)
%
% <html><h3>Syntax</h3></html>
%
% * |stat=kr.mse(x,y)| computes the MSE for the samples |(x,y)|.
%
% <html><h3>Description</h3></html>
%
% For a representative (sample,label) $(\mathbf{x},\mathbf{y})$ of the
% domain of interest and predicted values $\tilde{\mathbf{y}}$, the
% Mean Square Error is defined as:
%
% $$mse=\frac{1}{n}\sum_{i=1}^n\left(y^{(i)}-\tilde{y}^{(i)}\right)^2$$
%
% <html><h3>Example</h3></html>
f=@(x)x.*sin(x);
x=linspace(0,10,5)';y=f(x);
kr=CODES.fit.kriging(x,y);
x_t=linspace(0,10,1e4)';y_t=f(x_t);
err=kr.mse(x_t,y_t);
disp('Mean Square Error:')
disp(err)
%%
% <html><h3>See also</h3><a href=#auc>auc</a> | <a
% href=#me>me</a> | <a href=#rmse>rmse</a> | <a
% href=#rmae>rmae</a> | <a href=#r2>r2</a> | <a
% href=#cv>cv</a> | <a href=#loo>loo</a></html>
%
% <html><a id="rmse"></a></html>
%% rmse
% Compute the Root Mean Square Error (RMSE) for |(x,y)| (not for
% classification)
%
% <html><h3>Syntax</h3></html>
%
% * |stat=kr.rmse(x,y)| computes the RMSE for the samples |(x,y)|.
%
% <html><h3>Description</h3></html>
%
% For a representative (sample,label) $(\mathbf{x},\mathbf{y})$ of the
% domain of interest and predicted values $\tilde{\mathbf{y}}$, the
% Root Mean Square Error is defined as:
%
% $$rmse=\sqrt{\frac{1}{n}\sum_{i=1}^n\left(y^{(i)}-\tilde{y}^{(i)}\right)^2}$$
%
% <html><h3>Example</h3></html>
f=@(x)x.*sin(x);
x=linspace(0,10,5)';y=f(x);
kr=CODES.fit.kriging(x,y);
x_t=linspace(0,10,1e4)';y_t=f(x_t);
err=kr.rmse(x_t,y_t);
disp('Root Mean Square Error:')
disp(err)
%%
% <html><h3>See also</h3><a href=#auc>auc</a> | <a
% href=#me>me</a> | <a href=#mse>mse</a> | <a
% href=#rmae>rmae</a> | <a href=#r2>r2</a></html>
%
% <html><a id="nmse"></a></html>
%% nmse
% Compute the Normalized Mean Square Error (NMSE) (%) for |(x,y)| (not for
% classification)
%
% <html><h3>Syntax</h3></html>
%
% * |stat=kr.nmse(x,y)| computes the NMSE for the samples |(x,y)|.
%
% <html><h3>Description</h3></html>
%
% For a representative (sample,label) $(\mathbf{x},\mathbf{y})$ of the
% domain of interest and predicted values $\tilde{\mathbf{y}}$, the
% Normalized Mean Square Error is defined as:
%
% $$nmse=\frac{\sum_{i=1}^n\left(y^{(i)}-\tilde{y}^{(i)}\right)^2}{\sum_{i=1}^n\left(y^{(i)}-\bar{\mathbf{y}}\right)^2}$$
%
% where $\bar{\mathbf{y}}$ is the average of the training values
% $\mathbf{y}$.
%
% <html><h3>Example</h3></html>
f=@(x)x.*sin(x);
x=linspace(0,10,5)';y=f(x);
kr=CODES.fit.kriging(x,y);
x_t=linspace(0,10,1e4)';y_t=f(x_t);
err=kr.nmse(x_t,y_t);
disp('Normalized Mean Square Error:')
disp([num2str(err,'%5.2f') ' %'])
%%
% <html><h3>See also</h3><a href=#auc>auc</a> | <a
% href=#me>me</a> | <a href=#mse>mse</a> | <a href=#rmse>rmse</a> | <a
% href=#rmae>rmae</a> | <a href=#r2>r2</a></html>
%
% <html><a id="rmae"></a></html>
%% rmae
% Compute the Relative Maximum Absolute Error (RMAE) for |(x,y)| (not for
% classification)
%
% <html><h3>Syntax</h3></html>
%
% * |stat=kr.rmae(x,y)| computes the RMAE for the samples |(x,y)|.
%
% <html><h3>Description</h3></html>
%
% For a representative (sample,label) $(\mathbf{x},\mathbf{y})$ of the
% domain of interest and predicted values $\tilde{\mathbf{y}}$, the
% Relative Maximum Absolute Error is defined as:
%
% $$rmae=\frac{\mathop{\max}\limits_{i}\ \left|y^{(i)}-\tilde{y}^{(i)}\right|}{\sigma_\mathbf{y}}$$
%
% where $\sigma_\mathbf{y}$ is the standard deviation of the training
% values $\mathbf{y}$:
%
% $$\sigma_\mathbf{y}=\sqrt{\frac{1}{n-1}\sum_{i=1}^n\left(y^{(i)}-\bar{\mathbf{y}}\right)^2}$$
%
% where $\bar{\mathbf{y}}$ is the average of the training values
% $\mathbf{y}$.
%
% <html><h3>Example</h3></html>
f=@(x)x.*sin(x);
x=linspace(0,10,5)';y=f(x);
kr=CODES.fit.kriging(x,y);
x_t=linspace(0,10,1e4)';y_t=f(x_t);
err=kr.rmae(x_t,y_t);
disp('Relative Maximum Absolute Error:')
disp(err)
%%
% <html><h3>See also</h3><a href=#auc>auc</a> | <a
% href=#me>me</a> | <a href=#mse>mse</a> | <a href=#rmse>rmse</a> | <a
% href=#r2>r2</a></html>
%
% <html><a id="r2"></a></html>
%% r2
% Compute the coefficient of determination (R squared) for |(x,y)| (not for
% classification)
%
% <html><h3>Syntax</h3></html>
%
% * |stat=kr.r2(x,y)| computes the R squared for the samples |(x,y)|
% * |[stat,TSS]=kr.r2(x,y)| return the Total Sum of Squares |TSS|
% * |[stat,TSS,RSS]=kr.r2(x,y)| returns the Residual Sum of Squares
% |RSS|
%
% <html><h3>Description</h3></html>
%
% For a representative (sample,label) $(\mathbf{x},\mathbf{y})$ of the
% domain of interest and predicted values $\tilde{\mathbf{y}}$, the
% coefficient of determination is defined as:
%
% $$r2=1-\frac{RSS}{TSS}$$
%
% where:
%
% $$RSS=\sum_{i=1}^n\left(y^{(i)}-\tilde{y}^{(i)}\right)^2$$
%
% $$TSS=\sum_{i=1}^n\left(\tilde{y}^{(i)}-\bar{\mathbf{y}}\right)^2$$
%
% where $\bar{\mathbf{y}}$ is the average of the training values
% $\mathbf{y}$.
%
% <html><h3>Example</h3></html>
f=@(x)x.*sin(x);
x=linspace(0,10,5)';y=f(x);
kr=CODES.fit.kriging(x,y);
x_t=linspace(0,10,1e4)';y_t=f(x_t);
err=kr.r2(x_t,y_t);
disp('Coefficient of determination:')
disp(err)
%%
% <html><h3>See also</h3><a href=#auc>auc</a> | <a
% href=#me>me</a> | <a href=#mse>mse</a> | <a href=#rmse>rmse</a> | <a
% href=#rmae>rmae</a></html>
%
% <html><a id="me"></a></html>
%% me
% Compute the Misclassification Error (ME) for |(x,y)| (%)
%
% <html><h3>Syntax</h3></html>
%
% * |stat=kr.me(x,y)| compute the me for |(x,y)|
% * |stat=kr.me(x,y,use_balanced)| returns Balanced Misclassification
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
kr=CODES.fit.kriging(x,y);
x_t=linspace(0,10,1e4)';y_t=f(x_t);
err=kr.me(x_t,y_t);
bal_err=kr.me(x_t,y_t,true);
disp('On evenly balanced training set, standard and balanced prediction error return same values')
disp([err bal_err])
x=[2;5;8];y=f(x);
kr=CODES.fit.kriging(x,y);
err=kr.me(x_t,y_t);
bal_err=kr.me(x_t,y_t,true);
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
% * |stat=CODES.fit.kr.auc(x,y)| return the AUC |stat| for the samples
% |(x,y)|
% * |stat=CODES.fit.kr.auc(x,y,ROC)| plot the ROC curves if |ROC|is set
% to |true|
% * |[stat,FP,TP]=CODES.fit.kr.auc(...)| returns the false positive rate
% |FP| and the true positive rate |TP|
%
% <html><h3>Description</h3></html>
%
% A receiver operating characteristic (ROC) curve <#ref_metz Metz (1978)>
% is a graphical representation of the relation between true and false
% positive predictions for a binary classifier. It uses all possible
% decision thresholds from the prediction. In the case of kr
% classification, thresholds are defined by the kr values. More
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
kr=CODES.fit.kriging(x,y);
auc_val=kr.auc(kr.X,kr.Y);
x_t=rand(1000,2);
y_t=f(x_t);
auc_new=kr.auc(x_t,y_t);
disp(['AUC value over training set : ' num2str(auc_val,'%7.3f')])
disp([' AUC value over testing set : ' num2str(auc_new,'%7.3f')])
%%
% <html><h3>See also</h3><a href=#me>me</a> | <a
% href=#mse>mse</a> | <a href=#rmse>rmse</a> | <a href=#cv>cv</a></html>
%
% <html><a id="loo"></a></html>
%% loo
% Returns the Leave One Out (LOO) error (%)
%
% <html><h3>Syntax</h3></html>
%
% * |stat=kr.loo| return the loo error |stat|
% * |stat=kr.loo(param,value)| use set of parameters |param| and values
% |value| (_c.f._, <#params_loo parameter table>)
%
% <html><h3>Description</h3></html>
%
% Define $\tilde{l}^{(i)}$ the $i\textrm{\textsuperscript{th}}$ predicted
% label and $\tilde{l}_{-j}^{(i)}$ the $i\textrm{\textsuperscript{th}}$
% predicted label using the kr trained without the
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
kr=CODES.fit.kriging(x,y);
loo_err=kr.loo;
bal_loo_err=kr.loo('use_balanced',true);
disp('On evenly balanced training set, standard and balanced loo error return same values')
disp([loo_err bal_loo_err])
x=CODES.sampling.cvt(5,2);y=f(x);
kr=CODES.fit.kriging(x,y);
loo_err=kr.loo;
bal_loo_err=kr.loo('use_balanced',true);
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
% * |stat=kr.cv| return the cv error |stat|
% * |stat=kr.cv(param,value)| use set of parameters |param| and values
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
kr=CODES.fit.kriging(x,y);
rng(0); % To ensure same CV folds
cv_err=kr.cv;
rng(0);
bal_cv_err=kr.cv('use_balanced',true);
disp('On evenly balanced training set, standard and balanced cv error return same values')
disp([cv_err bal_cv_err])
x=CODES.sampling.cvt(31,2);y=f(x);
kr=CODES.fit.kriging(x,y);
rng(0);
cv_err=kr.cv;
rng(0);
bal_cv_err=kr.cv('use_balanced',true);
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
% * |stat=kr.class_change(kr_old,x)| compute the change of class of the
% sample |x| from meta-model |kr_old| to meta-model |kr| 
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
% convergence predicted label using |kr_old| (resp. |kr|).
%
% <html><h3>Example</h3></html>
f=@(x)x-4;
x=[2;8];y=f(x);
kr=CODES.fit.kriging(x,y);
x_t=linspace(0,10,1e4)';y_t=f(x_t);
err=kr.me(x_t,y_t);
kr_new=kr.add(5,f(5));
err_new=kr_new.me(x_t,y_t);
class_change=kr_new.class_change(kr,x_t);
disp(['Absolute change in prediction error : ' num2str(abs(err_new-err))])
disp(['Class change : ' num2str(class_change)])
%%
% <html><a id="plot"></a></html>
%% plot
% Display the kriging |kr|
%
% <html><h3>Syntax</h3></html>
%
% * |kr.plot| plot the meta-model |kr|
% * |kr.plot(param,value)| use set of parameters |param| and values
% |value| (_c.f._, <#params_plot parameter table>)
% * |h=kr.plot(...)| returns graphical handles
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
%     <td>numeric, {<tt>kr.lb_x</tt>}</td>
%     <td>Lower bound of plot</td>
%   </tr>
%   <tr>
%     <td><span class="string">'ub'</span></td>
%     <td>numeric, {<tt>kr.ub_x</tt>}</td>
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
%   <tr>
%     <td><span class="string">'CI'</span></td>
%     <td>logical, {<tt>true</tt>}</td>
%     <td>Display confidence interval on the predictor.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'alpha'</span></td>
%     <td>numeric, {0.05}</td>
%     <td>Significance level for (1-<tt>alpha</tt>) confidence interval.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'CI_color'</span></td>
%     <td>string or rgb color, {<span class="string">'k'</span>}</td>
%     <td>Color of the confidence interval.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'CI_alpha'</span></td>
%     <td>numeric, {<span class="string">0.3</span>}</td>
%     <td>Alpha (transparence) level of the conficende interval.</td>
%   </tr>
% </table></html>
%
% <html><h3>Example</h3></html>
f=@(x)x-4;
x=[2;8];y=f(x);
kr=CODES.fit.kriging(x,y);
kr.plot('new_fig',true)
%%
% <html><h3>See also</h3><a href=#isoplot>isoplot</a></html>
%
% <html><a id="isoplot"></a></html>
%% isoplot
% Display the 0 isocontour of the meta-model |kr|
%
% <html><h3>Syntax</h3></html>
%
% * |kr.isoplot| plot the 0 isocontour of the meta-model |kr|
% * |kr.isoplot(param,value)| use set of parameters |param| and values
% |value| (_c.f._, <#params_isoplot parameter table>)
% * |h=kr.isoplot(...)| returns graphical handles
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
%     <td>numeric, {<tt>kr.lb_x</tt>}</td>
%     <td>Lower bound of plot.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'ub'</span></td>
%     <td>numeric, {<tt>kr.ub_x</tt>}</td>
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
% </table></html>
%
% <html><h3>Example</h3></html>
f=@(x)x-4;
x=[2;8];y=f(x);
kr=CODES.fit.kriging(x,y);
kr.isoplot('new_fig',true)
%%
% <html><h3>See also</h3><a href=#isoplot>isoplot</a></html>
%%
% <html><a id="redLogLH"></a></html>
%% redLogLH
% Compute the reduced log likelihood
%
% <html><h3>Syntax</h3></html>
%
% * |lh=kr.redLogLH| compute the reduced log likelihood |lh| using
% parameters stored in |kr|.
% * |lh=kr.redLogLH(theta)| compute the reduced log likelihood |lh| using
% |theta|.
% * |lh=kr.redLogLH(theta,delta_2)| compute the reduced log likelihood |lh|
% using |theta| and |delta_2|.
%
% <html><h3>Example</h3></html>
kr=CODES.fit.kriging([1 1;20 2],[2;-1]);
lh1=kr.redLogLH;
lh2=kr.redLogLH(kr.theta,kr.sigma_n_2/kr.sigma_y_2);
lh3=kr.redLogLH(1,0);
disp([lh1 lh2 lh3])
%%
% <html><a id="plot"></a></html>
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
