%% <demo.html Examples> / <demo_method.html Adaptive sampling> / anti_lock
% This file is a complete demo of the capability of the |anti_lock|
% function from the CODES toolbox.
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Documentation
% The documentation for the |anti-lock| function can be found
% <anti_lock.html here>.
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
% Train an SVM, find a "max-min" sample and plot it:

svm=CODES.fit.svm(x,y);
x_al=CODES.sampling.anti_lock(svm,[0 0],[1 1]);

[X,Y]=meshgrid(linspace(0,1,100));
Z=reshape(f([X(:) Y(:)]),100,100);

figure('Position',[200 200 500 500])
contour(X,Y,Z,[0 0],'r')
hold on
svm.isoplot('lb',[0 0],'ub',[1 1],'prev_leg',{'True LS'})
plot(x_al(1),x_al(2),'ms')
axis square

%% Parallel vs serial and MultiStart
% Start a parallel pool:
gcp;
%%
% Compare compuational time of different scenarios to compute 10
% "anti-locking" samples:

CODES.common.disp_box('Using Matlab MultiStart')
tic;
svm=CODES.fit.svm(x,y);
CODES.sampling.anti_lock(svm,[0 0],[1 1],'nb',10,'MultiStart','MATLAB');
disp(['Serial : ' CODES.common.time(toc)])
tic;
svm=CODES.fit.svm(x,y,'UseParallel',true);
CODES.sampling.anti_lock(svm,[0 0],[1 1],'nb',10,'MultiStart','MATLAB');
disp(['Parallel : ' CODES.common.time(toc)])
CODES.common.disp_box('Using CODES MultiStart')
tic;
svm=CODES.fit.svm(x,y);
CODES.sampling.anti_lock(svm,[0 0],[1 1],'nb',10,'MultiStart','CODES');
disp(['Serial : ' CODES.common.time(toc)])
tic;
svm=CODES.fit.svm(x,y,'UseParallel',true);
CODES.sampling.anti_lock(svm,[0 0],[1 1],'nb',10,'MultiStart','CODES');
disp(['Parallel : ' CODES.common.time(toc)])

%% Display intermediate steps
% Display intermediate elements of the "anti-locking" calculation:

rng(0);
f=@(x)x(:,2)-sin(10*x(:,1))/4-0.5;
x=CODES.sampling.cvt(30,2);
y=f(x);

svm=CODES.fit.svm(x,y,'UseParallel',true);
[x_al,adds]=CODES.sampling.anti_lock(svm,[0 0],[1 1]);

[X,Y]=meshgrid(linspace(0,1,100));
Z=reshape(f([X(:) Y(:)]),100,100);

figure('Position',[200 200 500 500])
contour(X,Y,Z,[0 0],'r')
hold on
svm.isoplot('lb',[0 0],'ub',[1 1],'prev_leg',{'True LS'})
plot(adds{1}(1),adds{1}(2),'go')        % Plot center x_c
plot(adds{2}(:,1),adds{2}(:,2),'c--')   % Plot region boundary ||x-x_c||-R<=0
plot(x_al(1),x_al(2),'ms')
axis square

%% Parallel update
% On the same example, find 10 max-min samples and plot them:

f=@(x)x(:,2)-sin(10*x(:,1))/4-0.5;
x=CODES.sampling.cvt(30,2);
y=f(x);

svm=CODES.fit.svm(x,y,'UseParallel',true);
x_al=CODES.sampling.anti_lock(svm,[0 0],[1 1],'nb',10);

[X,Y]=meshgrid(linspace(0,1,100));
Z=reshape(f([X(:) Y(:)]),100,100);

figure('Position',[200 200 500 500])
contour(X,Y,Z,[0 0],'r')
hold on
svm.isoplot('lb',[0 0],'ub',[1 1],'prev_leg',{'True LS'})
plot(x_al(:,1),x_al(:,2),'ms')
axis square

%% Sequential refinement
% On the same example, for 20 iterations, find a "anti-locking" sample and
% update the svm with that sample:

f=@(x)x(:,2)-sin(10*x(:,1))/4-0.5;
x=CODES.sampling.cvt(30,2);
y=f(x);

svm=CODES.fit.svm(x,y,'UseParallel',true);

[X,Y]=meshgrid(linspace(0,1,100));
Z=reshape(f([X(:) Y(:)]),100,100);

%%
% Plot the first and last iterations:

[x_al,adds]=CODES.sampling.anti_lock(svm,[0 0],[1 1]);
svm=svm.add(x_al,f(x_al));

figure('Position',[200 200 500 500])
contour(X,Y,Z,[0 0],'r')
hold on
svm.isoplot('lb',[0 0],'ub',[1 1],'prev_leg',{'True LS'})
plot(adds{1}(1),adds{1}(2),'go')        % Plot center x_c
plot(adds{2}(:,1),adds{2}(:,2),'c--')   % Plot region boundary ||x-x_c||-R<=0
plot(x_al(:,1),x_al(:,2),'ms')
axis square

for i=2:20
    [x_al,adds]=CODES.sampling.anti_lock(svm,[0 0],[1 1]);
    svm=svm.add(x_al,f(x_al));
end

figure('Position',[200 200 500 500])
contour(X,Y,Z,[0 0],'r')
hold on
svm.isoplot('lb',[0 0],'ub',[1 1],'prev_leg',{'True LS'})
plot(adds{1}(1),adds{1}(2),'go')        % Plot center x_c
plot(adds{2}(:,1),adds{2}(:,2),'c--')   % Plot region boundary ||x-x_c||-R<=0
plot(x_al(:,1),x_al(:,2),'ms')
axis square

%%
% <html>
% <p><b>A video of this sequential update can be found <a
% href="matlab:file=strcat(fileparts(which('CODES.install')),'/+doc/html/Test_method_anti_lock_movie.mp4');disp(file);web(file,'-browser');">here</a>.
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
