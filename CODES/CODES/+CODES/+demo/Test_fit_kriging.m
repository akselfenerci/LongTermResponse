%% <demo.html Examples> / <demo_fit.html Meta-models> / kriging
% This file is a complete demo of the capability of the |kriging| class
% from the CODES toolbox.
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Documentation
% The documentation for the |kriging| class can be found <kriging.html
% here>.
%
%% Set rng
% Set random number generator seed:
rng(1)

%% Simple example
% Define a simple sinusoidal problem:

f=@(x)x.*sin(x);
x=CODES.sampling.cvt(10,1,'lb',0,'ub',10);
y=f(x);

%%
% Build and plot a Kriging without CI:

kr=CODES.fit.kriging(x,y);

figure('Position',[200 200 500 500])
plot(linspace(0,10,100)',f(linspace(0,10,100)'),'ro--')
hold on
kr.plot('prev_leg',{'true'},'psty','k^','lb',0,'ub',10,'CI',false)

%% Simple example for regression
% Define a simple sinusoidal problem with noise:

f=@(x)x.*sin(x);
f_noise=@(x)x.*sin(x)+normrnd(0,1,size(x,1),1);
x=CODES.sampling.cvt(10,1,'lb',0,'ub',10);
y=f_noise(x);

%%
% Build and plot a Kriging:

kr=CODES.fit.kriging(x,y,'regression',true);

figure('Position',[200 200 500 500])
plot(linspace(0,10,100)',f(linspace(0,10,100)'),'ro--')
hold on
plot(linspace(0,10,100)',f_noise(linspace(0,10,100)'),'gx--')
kr.plot('prev_leg',{'true','true noise'},'psty','k^','lb',0,'ub',10)

%% Compare CODES and DACE implementation
% Define a simple sinusoidal problem:

f=@(x)x.*sin(x);
x=CODES.sampling.cvt(5,1,'lb',0,'ub',10);
y=f(x);

%%
% Build and plot both Kriging:

kr=CODES.fit.kriging(x,y);
kr_dace=CODES.fit.kriging(x,y,'solver','DACE','theta',1,...
    'theta_min',0.01,'theta_max',100);

figure('Position',[200 200 500 500])
plot(linspace(0,10,100)',f(linspace(0,10,100)'),'ro--')
hold on
kr.plot('prev_leg',{'true'},'psty','k^','lb',0,'ub',10)
title('CODES')

figure('Position',[200 200 500 500])
plot(linspace(0,10,100)',f(linspace(0,10,100)'),'ro--')
hold on
kr_dace.plot('prev_leg',{'true'},'psty','k^','lb',0,'ub',10)
title('DACE')

%%
% Compare gradients

x_t=unifrnd(0,10,5,1);
[CODES_mean,CODES_var,CODES_mean_gr,CODES_var_gr]=kr.eval_all(x_t);
[DACE_mean,DACE_var,DACE_mean_gr,DACE_var_gr]=kr_dace.eval_all(x_t);

fprintf('\n%15s | %17s | %17s | %17s\n','Mean','Variance','Mean grad','Var grad');
disp(num2str([CODES_mean DACE_mean CODES_var DACE_var CODES_mean_gr DACE_mean_gr CODES_var_gr DACE_var_gr],'%8.3f %8.3f | %8.3f %8.3f | %8.3f %8.3f | %8.3f %8.3f'));

%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_dace"><a href="http://www.imm.dtu.dk/~hbni/dace">DACE Toolbox</a></li>
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
