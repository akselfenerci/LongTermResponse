%% <demo.html Examples> / <demo_fit.html Meta-models> / svm
% This file is a complete demo of the capability of the |svm| class from
% the CODES toolbox.
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

%% Simple example
% Define a simple sinusoidal problem:

f=@(x)x(:,2)-sin(10*x(:,1))/4-0.5;
x=CODES.sampling.cvt(30,2);
y=f(x);

%%
% Build and plot an SVM:

svm=CODES.fit.svm(x,y);

figure('Position',[200 200 500 500])
svm.isoplot

%% Linear vs Non-linear
% Build a linear and a non-linear svm to compare:

f=@(x)x(:,2)-sin(10*x(:,1))/4-0.5;
x=CODES.sampling.cvt(30,2);
y=f(x);

svm_lin=CODES.fit.svm(x,y,'kernel','lin','scale','square');
svm_gauss=CODES.fit.svm(x,y,'kernel','gauss');

figure('Position',[200 200 500 500])
svm_lin.isoplot('sv',false,'samples',false,'legend',false,'bcol','r')
hold on
svm_gauss.isoplot('sv',false,'legend',false,'bcol','b')
legend('Linear','Non-linear','-1 samples','+ 1samples')

%% Weighted SVM
% Compare standard and weighted SVM:

f=@(x)x(:,2)-sin(10*x(:,1))/4-0.5;
x=CODES.sampling.cvt(30,2);
y=f(x);

svm=CODES.fit.svm(x,y);
svm_weight=CODES.fit.svm(x,y,'weight',true,'w_plus',1,'w_minus',1e-3);

figure('Position',[200 200 500 500])
svm.isoplot('sv',false,'samples',false,'legend',false,'bcol','r')
hold on
svm_weight.isoplot('sv',false,'legend',false,'bcol','b')
legend('Standard','Weighted','-1 samples','+ 1samples')

%% Analytical gradient validation
% Compute analytical gradient and compare to gradient obtained using finite
% differences:

f=@(x)x(:,2)-sin(10*x(:,1))/4-0.5;
x=CODES.sampling.cvt(30,2);
y=f(x);

svm_dual=CODES.fit.svm(x,y,'solver','dual');
svm_libsvm=CODES.fit.svm(x,y,'solver','libsvm');

x_grad=[0.1 0.1;0.3 0.5;0.8 0.3;0.5 0.5];

CODES.common.disp_box('Gradient validation for dual solver')
[~,grad]=svm_dual.eval(x_grad);
grad_fd=CODES.common.grad_fd(@svm_dual.eval,x_grad);
disp(grad)
disp(grad_fd)

CODES.common.disp_box('Gradient validation for dual solver')
[~,grad]=svm_libsvm.eval(x_grad);
grad_fd=CODES.common.grad_fd(@svm_libsvm.eval,x_grad);
disp(grad)
disp(grad_fd)

%% Solver choice
% libSVM, presented in <#ref_libsvm Chang and Lin (2011)>, is a far
% superior solver all around and is the default. To illustrate, consider
% training a 20D dummy classifier with 1000 samples:

f=@(x)x(:,20)-0.5;
x=rand(1e3,20);
y=f(x);

time_dual=tic;
CODES.fit.svm(x,y,'solver','dual');
disp(['Dual formulation solved in ' CODES.common.time(toc(time_dual))]);
time_libsvm=tic;
CODES.fit.svm(x,y,'solver','libsvm');
disp(['libSVM solved in ' CODES.common.time(toc(time_libsvm))]);

%%
% In the specific case of linear SVM, the primal solver can have some
% appeal.

f=@(x)x(:,100)-0.5;
x=rand(1e4,100);
y=f(x);

time_primal=tic;
CODES.fit.svm(x,y,'solver','primal','kernel','lin');
disp(['Primal formulation solved in ' CODES.common.time(toc(time_primal))]);
time_libsvm=tic;
CODES.fit.svm(x,y,'solver','libsvm','kernel','lin');
disp(['libSVM solved in ' CODES.common.time(toc(time_libsvm))]);

%% References
% <html><ul style="list-style-type:none">
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
