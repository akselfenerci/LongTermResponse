%% <demo.html Examples> / <demo_fit.html Meta-models> / svm (parameters selection)
% This file shows different parameter selection techniques and how they
% pertain to the choice of kernel parameters
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Documentation
% The documentation for the |svm| class can be found <svm.html here>.
%
%% Set rng
% Set random number generator seed:
rng(0)

%% Concept
% When training a meta-model, one typically tries to do so such that it
% minimizes some metrics. In classification problems, that metric is often
% the generalization error, i.e., the integral of the
% misclassification over the domain
%
% $$err_{gen}=\int\mathcal{I}_{l(\mathbf{x})\neq \hat{l}(\mathbf{x})}\mathrm d\mathbf{x}$$
%
% where $l(\mathbf{x})$ is the true class and $\hat{l}(\mathbf{x})$ is the
% estimated class of $\mathbf{x}$. One can show that a Leave One Out (LOO)
% procedure yields an almost unbiased estimator of the generalization
% error, <#ref_loo Luntz and Brailovsky (1969)>. However, an LOO procedure
% may be numerically intractable. A Cross-Validation (CV), typically
% 10-fold, is usually faster and preferred as it is an estimator of the LOO
% error.
%
% Specifically for Support Vector Machine, <#ref_vap Vapnik (2000)> drew a
% link between the number of support vectors and the generalization
% capability of the model. Later on, <#ref_cha Chapelle et al. (2002)>
% develeped an estimate of the LOO error based on the span of the support
% vectors.
%
% In certain cases, such as highly unbalanced data, the generalization
% error is ill defined and the balanced generalization error makes more
% sense, <#ref_peng Jiang and Missoum (2014)>. The Area Under the Curve
% (AUC), <#ref_AUC Metz (1978)>, is also widely used.
%
% <html>Finally, over the years, heuristics have been developed to quickly
% guess a suitable value for the kernel parameters. Such heuristics can be
% cross kernel or kernel specific. The heuristic referred to as <span
% class='string'>'stiffest'</span> look for the most general case such that
% there is no misclassification error <a href=#ref_bas>(Basudhar and
% Missoum, 2010)</a>. The heuristic referred to as <span id="jaakkola_ref"
% class='string'>'fast'</span>, defined for the Gaussian kernel, defines 
% the kernel parameter as the mean of the pairwise distances between +1 and
% -1 samples <a href=#ref_jaakkola>(Jaakkola et al.,
% 1999)</a>.</html>
%
%% Simple 2D problem
% Consider a simple 2D classification problem:
f=@(x)x(:,2)-sin(10*x(:,1))/4-0.2;
x=CODES.sampling.cvt(200,2);
y=f(x);
[X,Y]=meshgrid(linspace(0,1,100));
Z=reshape(f([X(:) Y(:)]),100,100);
figure('Position',[200 200 500 500])
contour(X,Y,Z,[0 0],'k')
hold on
plot(x(y<=0,1),x(y<=0,2),'ro')
plot(x(y>0,1),x(y>0,2),'bo')
axis equal

%%
% For varying |theta|, train an SVM and compare the different
% aforementioned metrics:

svm=CODES.fit.svm(x,y);
[theta_lb,theta_ub,theta_mean]=svm.point_dist;  % Pairwise distances between +1 and -1 samples
thetas=linspace(theta_lb,theta_ub,20)';
loo=zeros(length(thetas),2);
cv=loo;Nsv=loo;chapelle=loo;auc=loo;
true_misc=loo;                               % True misclassification
X_t=[X(:) Y(:)];
Y_t=Z(:);

parfor i=1:length(thetas)
    svm_tmp=CODES.fit.svm(x,y,'theta',thetas(i),'C',1e4);
    loo(i,:)=[svm_tmp.loo svm_tmp.loo('use_balanced',true)];
    cv(i,:)=[svm_tmp.cv svm_tmp.cv('use_balanced',true)];
    Nsv(i,:)=[svm_tmp.N_sv_ratio svm_tmp.N_sv_ratio(true)];
    chapelle(i,:)=[svm_tmp.chapelle svm_tmp.chapelle(true)];
    auc(i,:)=100-[svm_tmp.auc(svm_tmp.X,svm_tmp.Y) svm_tmp.cv('metric','AUC')];
    true_misc(i,:)=[svm_tmp.me(X_t,Y_t) svm_tmp.me(X_t,Y_t)];
end
%%
% Plot a comparison of these metrics:

figure('Position',[200 200 750 500])
plot(thetas,true_misc(:,1),'k-.')
hold on
plot(thetas,loo(:,1),'r-')
plot(thetas,cv(:,1),'b-')
plot(thetas,Nsv(:,1),'c-')
plot(thetas,chapelle(:,1),'m-')
plot([theta_mean theta_mean],[0 max(max([loo;cv;Nsv;chapelle]))],'k--')
plot([theta_lb theta_lb],[0 max(max([loo;cv;Nsv;chapelle]))],'g--')
plot([theta_ub theta_ub],[0 max(max([loo;cv;Nsv;chapelle]))],'g--')
leg=legend('True','loo','cv','Nsv','Chapelle','Fast','Location','bestoutside');
set(leg,'interpreter','latex','FontSize',20)
set(gca,'xscale','log')
axis([0.99*theta_lb 1.01*theta_ub 0 40])
xlabel('$\theta$','interpreter','latex','FontSize',20)
ylabel('$err_{gen}$','interpreter','latex','FontSize',20)

figure('Position',[200 200 750 500])
plot(thetas,true_misc(:,2),'k-.')
hold on
plot(thetas,loo(:,2),'r-')
plot(thetas,cv(:,2),'b-')
plot(thetas,Nsv(:,2),'c-')
plot(thetas,chapelle(:,2),'m-')
plot(thetas,auc(:,1),'g-')
plot(thetas,auc(:,2),'g--')
plot([theta_mean theta_mean],[0 max(max([loo;cv;Nsv;chapelle]))],'k--')
plot([theta_lb theta_lb],[0 max(max([loo;cv;Nsv;chapelle]))],'g--')
plot([theta_ub theta_ub],[0 max(max([loo;cv;Nsv;chapelle]))],'g--')
leg=legend('True (bal)','loo (bal)','cv (bal)','Nsv (bal)','Chapelle (bal)','AUC','AUC (CV)','Fast','Location','bestoutside');
set(leg,'interpreter','latex','FontSize',20)
set(gca,'xscale','log')
axis([0.99*theta_lb 1.01*theta_ub 0 40])
xlabel('$\theta$','interpreter','latex','FontSize',20)
ylabel('$err_{gen}^{bal}$','interpreter','latex','FontSize',20)

%% Parameter selection strategy
% Train different SVMs using different metrics and compare them:

f=@(x)x(:,2)-sin(10*x(:,1))/4-0.5;
x=CODES.sampling.cvt(200,2);
y=f(x);

[X,Y]=meshgrid(linspace(0,1,100));
Z=reshape(f([X(:) Y(:)]),100,100);

tic;svm=CODES.fit.svm(x,y);time_fast=toc;
fast_err=svm.me([X(:) Y(:)],Z(:));
tic;svm1=CODES.fit.svm(x,y,'param_select','loo','UseParallel',true);time_loo=toc;
loo_err=svm1.me([X(:) Y(:)],Z(:));
tic;svm2=CODES.fit.svm(x,y,'param_select','chapelle');time_chapelle=toc;
chapelle_err=svm2.me([X(:) Y(:)],Z(:));
tic;svm3=CODES.fit.svm(x,y,'param_select','auc');time_auc=toc;
auc_err=svm3.me([X(:) Y(:)],Z(:));

disp(['Using fast,     theta=' num2str(svm.theta,'%5.3e') ', C=' num2str(svm.C,'%5.3e') ', err_gen=' num2str(fast_err,'%5.2f') '%, time=' CODES.common.time(time_fast)])
disp(['Using loo,      theta=' num2str(svm1.theta,'%5.3e') ', C=' num2str(svm1.C,'%5.3e') ', err_gen=' num2str(loo_err,'%5.2f') '%, time=' CODES.common.time(time_loo)])
disp(['Using chapelle, theta=' num2str(svm2.theta,'%5.3e') ', C=' num2str(svm2.C,'%5.3e') ', err_gen=' num2str(chapelle_err,'%5.2f') '%, time=' CODES.common.time(time_chapelle)])
disp(['Using auc,      theta=' num2str(svm3.theta,'%5.3e') ', C=' num2str(svm3.C,'%5.3e') ', err_gen=' num2str(auc_err,'%5.2f') '%, time=' CODES.common.time(time_auc)])

[X,Y]=meshgrid(linspace(0,1,100));
Z=reshape(f([X(:) Y(:)]),100,100);
figure('Position',[200 200 500 500])
contour(X,Y,Z,[0 0],'k')
hold on
svm.isoplot('legend',false,'samples',false,'sv',false,'bcol','r')
svm1.isoplot('legend',false,'samples',false,'sv',false,'bcol','b')
svm2.isoplot('legend',false,'samples',false,'sv',false,'bcol','m')
svm3.isoplot('legend',false,'samples',false,'sv',false,'bcol','g')
legend('True','fast','loo','chapelle','auc')

%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_loo"><span style="color:#005fce;">Luntz and Brailovsky
%   (1969)</span>: Luntz A., Brailovsky V., (1969) <i>On estimation of
%   characters obtained in statistical procedure of recognition</i>.
%   Technicheskaya Kibernetica 3(6):6-12</li>
%   <li id="ref_auc"><span style="color:#005fce;">Metz (1978)</span>: Metz
%   C. E., (1978) <i>Basic principles of ROC analysis. Seminars in Nuclear
%   Medicine</i>. Technicheskaya Kibernetica 8(4):283-298 - <a
%   href="http://dx.doi.org/10.1016/S0001-2998(78)80014-2">DOI</a></li>
%   <li id="ref_jaakkola"><span style="color:#005fce;">Jaakkola et al.
%   (1999)</span>: Jaakkola T., Diekhans M., Haussler D., (1999)
%   <i>Using the Fisher kernel method to detect remote protein
%   homologies</i>. In: International Conference on Intelligent Systems for
%   Molecular Biology. 149-158 - <a
%   href="http://www.ncbi.nlm.nih.gov/pubmed/10786297">PMID</a></li>
%   <li id="ref_vap"><span style="color:#005fce;">Vapnik (2000)</span>:
%   Vapnik V., (2000) <i>The nature of statistical learning theory</i>.
%   Springer</li>
%   <li id="ref_cha"><span style="color:#005fce;">Chapelle et al.
%   (2002)</span>: Chapelle O., Vapnik V., Bousquet O., Mukherjee S.,
%   (2002) <i>Choosing multiple parameters for support vector machines</i>.
%   Machine Learning 46(1-3):131-159 - <a 
%   href="http://dx.doi.org/10.1023/A:1012450327387">DOI</a></li>
%   <li id="ref_bas"><span style="color:#005fce;">Basudhar and Missoum
%   (2010)</span>: Basudhar A., Missoum S., (2010) <i>An improved adaptive 
%   sampling scheme for the construction of explicit boundaries</i>.
%   Structural and Multidisciplinary Optimization 42(4):517-529 - <a
%   href="http://dx.doi.org/10.1007/s00158-010-0511-0">DOI</a></li>
%   <li id="ref_peng"><span style="color:#005fce;">Jiang and Missoum
%   (2014)</span>: Jiang P., Missoum S., (2014) <i>Optimal SVM parameter
%   selection for non-separable and unbalanced datasets</i>. Structural and
%   Multidisciplinary Optimization 50(4):523-535 - <a 
%   href="http://dx.doi.org/10.1007/s00158-014-1105-z">DOI</a></li>
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
