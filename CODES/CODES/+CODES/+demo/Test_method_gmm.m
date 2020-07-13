%% <demo.html Examples> / <demo_method.html Adaptive sampling> / gmm
% This file is a complete demo of the capability of the |gmm| function from
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
% The documentation for the |gmm| function can be found <gmm.html here>.
%
%% Set rng
% Set random number generator seed:
rng(0)

%% Simple example
% Define a 2D reliability problem with 4 failure domains:

f=@CODES.test.inverse_2D;
[X,Y]=meshgrid(linspace(-5,5,100));
Z=reshape(f([X(:) Y(:)]),100,100);
figure('Position',[200 200 500 500])
contour(X,Y,Z,[0 0],'k')

%%
% Obtain a DOE:
x=CODES.sampling.cvt(30,2,'lb',[-5 -5],'ub',[5 5],'region',@(x)5-pdist2(x,[0 0]));
y=f(x);

%%
% Derive and check log JPDF and gradient (normal distribution):

logjpdf=@(x)sum(-0.5*x.^2-0.5*log(2*pi),2);     % equivalent to logjpdf=@(x)sum(log(normpdf(x)),2);
dlogjpdf=@(x)-x;
test_rng=@(N)normrnd(0,1,[N 2]);                % normal random sampler for optimization starting points

x_grad=[0.1 0.1;0.3 0.5;0.8 0.3;0.5 0.5];
grad=dlogjpdf(x_grad);
grad_fd=CODES.common.grad_fd(logjpdf,x_grad);

disp([['Analytical gradients :';...
       '                      ';...
       '  Finite differences :';...
       '                      '] num2str([grad';grad_fd'],'%1.3f  ')])

%%
% Train an SVM, then find and plot a generalized "max-min" sample:

svm=CODES.fit.svm(x,y);
x_gmm=CODES.sampling.gmm(svm,logjpdf,test_rng,'dlogjpdf',dlogjpdf);

figure('Position',[200 200 500 500])
contour(X,Y,Z,[0 0],'r')
hold on
svm.isoplot('lb',[-5 -5],'ub',[5 5],'prev_leg',{'True LS'})
plot(x_gmm(1),x_gmm(2),'ms')
axis square

%% Comparison of Computational Time for: Parallel and Serial; With and Without Derivative; and Matlab and CODES Multistart:
% Start a parallel pool:
gcp;
%%
% Compare compuational time of different scenarios to compute 10 generalized
% "max-min" samples

CODES.common.disp_box('Using Matlab MultiStart')
tic;
svm=CODES.fit.svm(x,y);
CODES.sampling.gmm(svm,logjpdf,test_rng,'nb',10,'MultiStart','MATLAB');
disp(['Serial without derivative : ' CODES.common.time(toc)])
tic;
svm=CODES.fit.svm(x,y,'UseParallel',true);
CODES.sampling.gmm(svm,logjpdf,test_rng,'nb',10,'MultiStart','MATLAB');
disp(['Parallel without derivative: ' CODES.common.time(toc)])
tic;
svm=CODES.fit.svm(x,y);
CODES.sampling.gmm(svm,logjpdf,test_rng,'dlogjpdf',dlogjpdf,'nb',10,'MultiStart','MATLAB');
disp(['Serial with derivative: ' CODES.common.time(toc)])
tic;
svm=CODES.fit.svm(x,y,'UseParallel',true);
CODES.sampling.gmm(svm,logjpdf,test_rng,'dlogjpdf',dlogjpdf,'nb',10,'MultiStart','MATLAB');
disp(['Parallel with derivative: ' CODES.common.time(toc)])
CODES.common.disp_box('Using CODES MultiStart')
tic;
svm=CODES.fit.svm(x,y);
CODES.sampling.gmm(svm,logjpdf,test_rng,'nb',10,'MultiStart','CODES');
disp(['Serial without derivative : ' CODES.common.time(toc)])
tic;
svm=CODES.fit.svm(x,y,'UseParallel',true);
CODES.sampling.gmm(svm,logjpdf,test_rng,'nb',10,'MultiStart','CODES');
disp(['Parallel without derivative: ' CODES.common.time(toc)])
tic;
svm=CODES.fit.svm(x,y);
CODES.sampling.gmm(svm,logjpdf,test_rng,'dlogjpdf',dlogjpdf,'nb',10,'MultiStart','CODES');
disp(['Serial with derivative: ' CODES.common.time(toc)])
tic;
svm=CODES.fit.svm(x,y,'UseParallel',true);
CODES.sampling.gmm(svm,logjpdf,test_rng,'dlogjpdf',dlogjpdf,'nb',10,'MultiStart','CODES');
disp(['Parallel with derivative: ' CODES.common.time(toc)])

%% Parallel update
% On the same example, find and plot 10 generalized "max-min" samples:

f=@CODES.test.inverse_2D;
x=CODES.sampling.cvt(30,2,'lb',[-5 -5],'ub',[5 5],'region',@(x)5-pdist2(x,[0 0]));
y=f(x);

svm=CODES.fit.svm(x,y,'UseParallel',true);
x_gmm=CODES.sampling.gmm(svm,logjpdf,test_rng,'dlogjpdf',dlogjpdf,'nb',10);

[X,Y]=meshgrid(linspace(-5,5,100));
Z=reshape(f([X(:) Y(:)]),100,100);

figure('Position',[200 200 500 500])
contour(X,Y,Z,[0 0],'r')
hold on
svm.isoplot('lb',[-5 -5],'ub',[5 5],'prev_leg',{'True LS'})
plot(x_gmm(:,1),x_gmm(:,2),'ms')
axis square

%% Sequential refinement
% On the same example, for 20 iterations, find a "max-min" sample and
% update the svm:

f=@CODES.test.inverse_2D;
x=CODES.sampling.cvt(30,2,'lb',[-5 -5],'ub',[5 5],'region',@(x)5-pdist2(x,[0 0]));
y=f(x);

svm=CODES.fit.svm(x,y,'UseParallel',true);

[X,Y]=meshgrid(linspace(-5,5,100));
Z=reshape(f([X(:) Y(:)]),100,100);

%%
% Plot first and last iteration:

x_gmm=CODES.sampling.gmm(svm,logjpdf,test_rng,'dlogjpdf',dlogjpdf);
svm=svm.add(x_gmm,f(x_gmm));
    
figure('Position',[200 200 500 500])
contour(X,Y,Z,[0 0],'r')
hold on
svm.isoplot('lb',[-5 -5],'ub',[5 5],'prev_leg',{'True LS'})
plot(x_gmm(:,1),x_gmm(:,2),'ms')
axis square
axis square

for i=2:20
    x_gmm=CODES.sampling.gmm(svm,logjpdf,test_rng,'dlogjpdf',dlogjpdf);
    svm=svm.add(x_gmm,f(x_gmm));
end

figure('Position',[200 200 500 500])
contour(X,Y,Z,[0 0],'r')
hold on
svm.isoplot('lb',[-5 -5],'ub',[5 5],'prev_leg',{'True LS'})
plot(x_gmm(:,1),x_gmm(:,2),'ms')
axis square
axis square
%%
% <html>
% <p><b>A video of this sequential update can be found <a
% href="matlab:file=strcat(fileparts(which('CODES.install')),'/+doc/html/Test_method_gmm_movie.mp4');disp(file);web(file,'-browser');">here</a>.
% </b></p>
% </html>
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
