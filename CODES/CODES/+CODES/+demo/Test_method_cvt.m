%% <demo.html Examples> / <demo_method.html Adaptive sampling> / cvt
% This file is a complete demo of the capability of the |cvt| function from
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
% The documentation for the |cvt| function can be found
% <cvt.html here>.
%
%% Set rng
% Set random number generator seed:
rng(0)

%% Simple example
% Build a simple CVT DOE within a square of side length 10 centered on the
% origin:

DOE=CODES.sampling.cvt(100,2,'lb',[-5 -5],'ub',[5 5]);

figure('Position',[200 200 500 500])
plot(DOE(:,1),DOE(:,2),'bo')
axis square
axis([-5 5 -5 5])

%% Restricted DOE
% Observe the previous DOE overlayed with a normal distribution:

JPDF=@(x)mvnpdf(x,[0 0],[1 0;0 1]);
[X,Y]=meshgrid(linspace(-5,5,100));
Z=reshape(JPDF([X(:) Y(:)]),100,100);

figure('Position',[200 200 500 500])
contour(X,Y,Z,50)
hold on
plot(DOE(:,1),DOE(:,2),'b.')
axis square
axis([-5 5 -5 5])

%%
% A better DOE would be to have CVT samples restricted within a circle:

DOE=CODES.sampling.cvt(100,2,'lb',[-5 -5],'ub',[5 5],'region',@(x)5-pdist2(x,[0 0]));

figure('Position',[200 200 500 500])
contour(X,Y,Z,50)
hold on
plot(DOE(:,1),DOE(:,2),'b.')
axis square
axis([-5 5 -5 5])

%% Distribution tailored DOE
% The previous example relied on previous knowledge for the definition of
% the _region_. Another idea is to use isovalues of the target distribution
% as the _region_ boundary. For example, consider a correlated Gaussian example
% as follows:

JPDF=@(x)mvnpdf(x,[0 0],[1 0.7;0.7 1]);
ndummies=mvnrnd([0 0],[1 0.7;0.7 1],1e5);
[X,Y]=meshgrid(linspace(-5,5,100));
Z=reshape(JPDF([X(:) Y(:)]),100,100);

tic;
DOE=CODES.sampling.cvt(100,2,'lb',[-5 -5],'ub',[5 5],...
    'dummies',ndummies,'display',false);
disp(['Time to find CVT with prescribed dummies : ' CODES.common.time(toc)])
tic;
DOE1=CODES.sampling.cvt(100,2,'lb',[-5 -5],'ub',[5 5],...
    'dummies',ndummies,'kmeans',true);
disp(['Time to find CVT with prescribed dummies and matlab built-in kmeans : ' CODES.common.time(toc)])
tic;
DOE2=CODES.sampling.cvt(100,2,'lb',[-5 -5],'ub',[5 5],...
    'region',@(x)JPDF(x)-JPDF([4 4]),'display',false);
disp(['Time to find CVT with shuffled Halton dummies : ' CODES.common.time(toc)])
tic;
DOE3=CODES.sampling.cvt(100,2,'lb',[-5 -5],'ub',[5 5],...
    'region',@(x)JPDF(x)-JPDF([4 4]),'kmeans',true);
disp(['Time to find CVT with matlab built-in kmeans : ' CODES.common.time(toc)])

figure('Position',[200 200 500 500])
contour(X,Y,Z,50)
hold on
plot(DOE(:,1),DOE(:,2),'b.')
axis square
axis([-5 5 -5 5])

figure('Position',[200 200 500 500])
contour(X,Y,Z,50)
hold on
plot(DOE1(:,1),DOE1(:,2),'b.')
axis square
axis([-5 5 -5 5])

figure('Position',[200 200 500 500])
contour(X,Y,Z,50)
hold on
plot(DOE2(:,1),DOE2(:,2),'b.')
axis square
axis([-5 5 -5 5])

figure('Position',[200 200 500 500])
contour(X,Y,Z,50)
hold on
plot(DOE3(:,1),DOE3(:,2),'b.')
axis square
axis([-5 5 -5 5])

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
