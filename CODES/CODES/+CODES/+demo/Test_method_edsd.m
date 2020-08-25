%% <demo.html Examples> / <demo_method.html Adaptive sampling> / edsd
% This file is a complete demo of the capability of the |edsd|function from
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
% The documentation for the |edsd| function can be found <edsd.html here>.
%
%% Set rng
% Set random number generator seed:
rng(0)

%% Simple example
% Define a simple sinusoidal problem:

f=@(x)x(:,2)-sin(10*x(:,1))/4-0.5;
x=CODES.sampling.cvt(10,2);
y=f(x);

%%
% Train an SVM and perform edsd while watching the convergence plot:

svm=CODES.fit.svm(x,y,'UseParallel',true);
svm_col=CODES.sampling.edsd(f,svm,[0 0],[1 1],'iter_max',20,'plot_conv',true,'display_edsd',false);

%%
% Plot first and last contour:

[X,Y]=meshgrid(linspace(0,1,100));
Z=reshape(f([X(:) Y(:)]),100,100);

figure('Position',[200 200 500 500])
contour(X,Y,Z,[0 0],'r')
hold on
svm_col{1}.isoplot('lb',[0 0],'ub',[1 1],'prev_leg',{'True LS'})
axis square

figure('Position',[200 200 500 500])
contour(X,Y,Z,[0 0],'r')
hold on
svm_col{end}.isoplot('lb',[0 0],'ub',[1 1],'prev_leg',{'True LS'})
axis square

%%
% <html>
% <p><b>A video of this sequential update can be found <a
% href="matlab:file=strcat(fileparts(which('CODES.install')),'/+doc/html/Test_method_edsd_movie.mp4');disp(file);web(file,'-browser');">here</a>.
% </b></p>
% </html>
%% Obtain classification error statistics
% Compare the relative change of class, used as a convergence metric in
% <#ref_bas Basudhar and Missoum (2008)>, to the generalization
% error:

error_gen=zeros(size(svm_col,1),1);
class_change=zeros(size(svm_col,1)-1,1);

for i=1:size(svm_col,1)
    error_gen(i,:)=svm_col{i}.me([X(:) Y(:)],Z(:));
    if i>1
        class_change(i-1,:)=svm_col{i}.class_change(svm_col{i-1},[X(:) Y(:)]);
    end
end

figure('Position',[200 200 500 500])
plot(1:size(svm_col,1),error_gen(:,1),'b-')
hold on
plot(2:size(svm_col,1),class_change(:,1),'r-')
plot(2:size(svm_col,1),abs(diff(error_gen(:,1))),'g-')
legend('Generalization error','Class change','Absolute change in generalization error')

%% Plot functions
% Perform a simple EDSD and plot AUC on a test set:
f=@(x)x(:,2)-sin(10*x(:,1))/4-0.5;
x=CODES.sampling.cvt(10,2);
y=f(x);

x_t=rand(1e4,2);
y_t=f(x_t);

plot_auc=@(svm,iter)plot(iter,svm.auc(x_t,y_t),'bs');

svm=CODES.fit.svm(x,y,'UseParallel',true);
[~]=CODES.sampling.edsd(f,svm,[0 0],[1 1],'iter_max',5,'plot_conv',true,'plotfcn',plot_auc);

%% Obtain extra outputs from the function
% Consider a function that returns other information than just the
% performance. For example, consider a dummy function returning
% 3 random numbers for each sample calculated.
f=@(x)deal(x(:,2)-sin(10*x(:,1))/4-0.5,num2cell(rand(size(x,1),3)));
x=CODES.sampling.cvt(10,2);
[y,extra_outputs]=f(x);

svm=CODES.fit.svm(x,y,'UseParallel',true);
[svm_col,extras]=CODES.sampling.edsd(f,svm,[0 0],[1 1],'iter_max',5,'extra_output',true);

disp([svm_col{end}.X [cell2mat(extra_outputs);cell2mat(extras)]])

%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_bas"><span style="color:#005fce;">Basudhar and Missoum
%   (2008)</span>: Basudhar A., Missoum S., (2008) <i>Adaptive explicit
%   decision functions for probabilistic design and optimization using
%   support vector machines</i>. Computers &amp; Structures
%   86(19):1904-1917 - <a
%   href="http://dx.doi.org/10.1016/j.compstruc.2008.02.008">DOI</a></li>
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
