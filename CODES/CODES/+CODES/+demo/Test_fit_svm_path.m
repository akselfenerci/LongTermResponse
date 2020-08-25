%% <demo.html Examples> / <demo_fit.html Meta-models> / svm (SVM path)
% This file illustrates the notion of SVM path as a possible feature to
% improve selection of the cost parameter.
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

%% 2D example (Linear SVM)
% On a simple example, obtain an initial DOE:

f=@(x)x(:,2)-sin(10*x(:,1))/4-0.5;
x=CODES.sampling.cvt(20,2);
y=f(x);

%%
% For different values of |C|, train an SVM and collect the values of |b|,
% |beta| and |alpha| for each value of |C|:

C=linspace(1,50,50)';
SVMs=cell(length(C),1);
bias=zeros(size(C,1),1);
betas=zeros(2,size(C,1));
alphas=zeros(size(x,1),size(C,1));
for i=1:length(C)
    SVMs{i}=CODES.fit.svm(x,y,'kernel','lin','C',C(i),'solver','primal');
    bias(i)=SVMs{i}.bias;
    betas(:,i)=SVMs{i}.beta;
    alphas(:,i)=SVMs{i}.alphas;
end

%%
% Plot the collected value. Observe the piecewise linear behavior:

figure('Position',[200 200 500 500])
plot(C,bias,'b')
hold on
plot(C,betas(1,:),'r')
plot(C,betas(2,:),'g')
leg=legend('$b (\beta_0)$','$\beta_1$','$\beta_2$');
set(leg,'interpreter','latex','FontSize',20,'Location','Best')
xlabel('$C$','interpreter','latex','FontSize',20)

figure('Position',[200 200 500 500])
plot(C,C,'r:','LineWidth',3)
hold on
plot(C,alphas)
xlabel('$C$','interpreter','latex','FontSize',20)
ylabel('$\alpha_i$','interpreter','latex','FontSize',20)

%% 2D example (Non-linear SVM)
% For different values of |C| (|theta| fixed), train an SVM and collect the
% values of |b|, |beta| and |alpha| for each value of |C|:

C=linspace(1,50,200)';
SVMs=cell(length(C),1);
bias=zeros(size(C,1),1);
betas=zeros(2,size(C,1));
alphas=zeros(size(x,1),size(C,1));
for i=1:length(C)
    SVMs{i}=CODES.fit.svm(x,y,'theta',0.7325,'kernel','gauss','C',C(i));
    bias(i)=SVMs{i}.bias;
    alphas(:,i)=SVMs{i}.alphas;
end

%%
% Plot the collected value. Observe the piecewise linear behavior (noise is
% due to numerical error in solver convergence):

figure('Position',[200 200 500 500])
plot(C,C,'r:','LineWidth',3)
hold on
plot(C,alphas)
xlabel('$C$','interpreter','latex','FontSize',20)
ylabel('$\alpha_i$','interpreter','latex','FontSize',20)

%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_libsvm"><span style="color:#005fce;">Hastie et al.
%   (2004)</span>: Hastie T., Rosset S., Tibshirani R., and Zhu J.
%   (2004)<i>The entire regularization path for the support vector
%   machine.</i> Journal of Machine Learning Research, 5:1391-1415.</li>
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
