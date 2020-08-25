%% <demo.html Examples> / <demo_reliability.html Reliability assessment> / mc
% This file is a complete demo of the capability of the |mc| function
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
% The documentation for the |mc| function can be found <mc.html here>.
%
%% Set rng
% Set random number generator seed:
rng(0)

%% Simple linear example
% Compute the CMC $\hat{P}_f$ on a simple linear example:

g=@CODES.test.lin;
res_mc=CODES.reliability.mc(g,2,'vectorial',true);
disp(res_mc)

%%
% Ensure a CoV of variation of at most 1%:

res_mc=CODES.reliability.mc(g,2,'vectorial',true,'CoV',1);
disp(res_mc)

%% Sampler or Tinv
% Sampler and Tinv are mutually exclusive and there almost always exist an
% equivalent from one to another. For example, for exponential distribution:

sampler=@(N)exprnd(0.5,N,2);
Tinv=@(u)expinv(normcdf(u),0.5);
res_mc1=CODES.reliability.mc(g,2,'vectorial',true,'CoV',1,'sampler',sampler);
res_mc2=CODES.reliability.mc(g,2,'vectorial',true,'CoV',1,'Tinv',Tinv);
CODES.common.disp_matrix([res_mc1.Pf res_mc2.Pf;res_mc1.beta res_mc2.beta;...
    res_mc1.CoV res_mc2.CoV],{'Pf','beta','CoV'},{'Sampler','Tinv'})

%%
% In thegeneral case, the sampler function can be slightly more involved.
% For example, if the joint PDF is defined by 2 independent gaussian with
% respective mean 5 and 3 and respective standard deviation 2 and 1, a
% sampler function should read:

sampler=@(N)normrnd(repmat([5 3],N,1),repmat([2 1],N,1));
res_mc1=CODES.reliability.mc(g,2,'vectorial',true,'CoV',1,'sampler',sampler);
disp(res_mc1)

%% Save Monte-Carlo samples

res_mc=CODES.reliability.mc(g,2,'vectorial',true,'store',true);
disp(res_mc)

%% Use user defined random sample

res_mc=CODES.reliability.mc(g,normrnd(0,1,1e5,2),'vectorial',true);
disp(res_mc)

%%
% <html><a id="sensitivities"></a></html>
%% Compute sensitivities dPfdtheta
% Here are two examples on how to compute sensitivities of the estimated
% probability of failure. See <mc.html#sensitivities |mc| help> for details
% on the options.
%
% Using a simple standard gaussian space and a linear limit state:

d=3;
g=@(x)-x(:,2)-x(:,1)+d;
beta=@(mus)(d-sum(mus))/sqrt(2);
dbetadtheta=-1/sqrt(2)*ones(1,2);
dPdfdtheta=@(mus)-dbetadtheta*normpdf(-beta(mus));

lnPDF=@(x,mus)sum(log(normpdf(x,mus,[1 1])),2);
dlnPDF=@(x,mus)bsxfun(@minus,x,repmat(mus,size(x,1),1));

tic;
res_mc=CODES.reliability.mc(g,2,'vectorial',true,'lnPDF',lnPDF,'theta',[0 0]);
time_ln=toc;
tic;
res_mc1=CODES.reliability.mc(g,2,'vectorial',true,'dlnPDF',@(x)dlnPDF(x,[0 0]));
time_dln=toc;

CODES.common.disp_matrix([res_mc.dPfdtheta res_mc.dbetadtheta time_ln;...
    res_mc1.dPfdtheta res_mc1.dbetadtheta time_dln;
    dPdfdtheta([0 0]) dbetadtheta 0],{'ln','dln','ref'},...
    {'dPfdtheta1','dPfdtheta2','dbetadtheta1','dbetadtheta2','time'});

%% Compute sensitivities dPfdz
% Using a simple standard gaussian space and a linear limit state:

d=3;
z=[1 2];
g=@(x)deal(-sum(z)-x+d,-ones(size(x,2),1));
Pf=@(z)1-normcdf(d-sum(z));
beta=@(z)-norminv(Pf(z));
dPfdz=@(z)normpdf(d-sum(z));
dbetadz=@(z)-dPfdz(z)/normpdf(-beta(z));

res_mc=CODES.reliability.mc(g,1,'vectorial',true,'nz',2);

CODES.common.disp_matrix([res_mc.dPfdz res_mc.dbetadz;...
    dPfdz(z) dPfdz(z) dbetadz(z) dbetadz(z)],{'est','ref'},...
    {'dPfdz1','dPfdz2','dbetadz1','dbetadz2'});

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
