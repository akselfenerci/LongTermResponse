%% <demo.html Examples> / <demo_reliability.html Reliability assessment> / iform
% This file is a complete demo of the capability of the |iform| function
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
% The documentation for the |iform| function can be found <iform.html
% here>. The  examples used are taken from <#ref_youn Youn et al. (2003)>.
%
%% Set rng
% Set random number generator seed:
rng(0)

%% Example 1: Convex
% Compute the MPTP on a simple 2D convex problem

g=@(x)-exp(x(:,1)-7)-x(:,2)+10;
T=@(x)(x-6)/0.8;
Tinv=@(u)u*0.8+6;

res_sqp=CODES.reliability.iform(g,2,3,'solver','sqp','Tinv',Tinv);
res_amv=CODES.reliability.iform(g,2,3,'solver','amv','Tinv',Tinv);
res_cmv=CODES.reliability.iform(g,2,3,'solver','cmv','Tinv',Tinv);
res_hmv=CODES.reliability.iform(g,2,3,'solver','hmv','Tinv',Tinv);

CODES.common.disp_matrix([res_sqp.LS_count res_sqp.MPTP res_sqp.PPM;...
                          res_amv.LS_count res_amv.MPTP res_amv.PPM;...
                          res_cmv.LS_count res_cmv.MPTP res_cmv.PPM;...
                          res_hmv.LS_count res_hmv.MPTP res_hmv.PPM],...
                         {'SQP','AMV','CMV','HMV'},...
                         {'# func. call','MPTP_1','MPTP_2','PPM'})

%%
% Provide plot

[X,Y]=meshgrid(linspace(-4,4,100));
Z=reshape(g(Tinv([X(:) Y(:)])),size(X));
figure('Position',[200 200 500 500])
Colors=get(gca,'ColorOrder');
contour(X,Y,Z,[0 0],'Color',Colors(end,:))
hold on
u_MPP=T(res_sqp.MPTP);
plot(u_MPP(1),u_MPP(2),'s',...
    'MarkerFaceColor',Colors(1,:),'MarkerEdgeColor',Colors(1,:))

%% Example 2: Concave
% Compute the MPTP on a simple 2D concave problem

g=@(x)(exp(0.8*x(:,1)-1.2)+exp(0.7*x(:,2)-0.6)-5)/10;
T=@(x)bsxfun(@rdivide,bsxfun(@minus,x,[4 5]),[0.8 0.8]);
Tinv=@(u)bsxfun(@plus,bsxfun(@times,u,[0.8 0.8]),[4 5]);

res_sqp=CODES.reliability.iform(g,2,3,'solver','sqp','Tinv',Tinv);
res_amv=CODES.reliability.iform(g,2,3,'solver','amv','Tinv',Tinv);
res_cmv=CODES.reliability.iform(g,2,3,'solver','cmv','Tinv',Tinv);
res_hmv=CODES.reliability.iform(g,2,3,'solver','hmv','Tinv',Tinv);

CODES.common.disp_matrix([res_sqp.LS_count res_sqp.MPTP res_sqp.PPM;...
                          res_amv.LS_count res_amv.MPTP res_amv.PPM;...
                          res_cmv.LS_count res_cmv.MPTP res_cmv.PPM;...
                          res_hmv.LS_count res_hmv.MPTP res_hmv.PPM],...
                         {'SQP','AMV','CMV','HMV'},...
                         {'# func. call','MPTP_1','MPTP_2','PPM'})

%%
% Provide plot

[X,Y]=meshgrid(linspace(-4,4,100));
Z=reshape(g(Tinv([X(:) Y(:)])),size(X));
figure('Position',[200 200 500 500])
Colors=get(gca,'ColorOrder');
contour(X,Y,Z,[0 0],'Color',Colors(end,:))
hold on
u_MPP=T(res_sqp.MPTP);
plot(u_MPP(1),u_MPP(2),'s',...
    'MarkerFaceColor',Colors(1,:),'MarkerEdgeColor',Colors(1,:))

%% Example 3: Concave
% Compute the MPTP on a simple 2D concave problem

g=@(x)0.3*x(:,1).^2.*x(:,2)-x(:,2)+0.8*x(:,1)+1;
T=@(x)bsxfun(@rdivide,bsxfun(@minus,x,[1.3 1]),[0.55 0.55]);
Tinv=@(u)bsxfun(@plus,bsxfun(@times,u,[0.55 0.55]),[1.3 1]);

res_sqp=CODES.reliability.iform(g,2,3,'solver','sqp','Tinv',Tinv);
res_amv=CODES.reliability.iform(g,2,3,'solver','amv','Tinv',Tinv);
res_cmv=CODES.reliability.iform(g,2,3,'solver','cmv','Tinv',Tinv);
res_hmv=CODES.reliability.iform(g,2,3,'solver','hmv','Tinv',Tinv);

CODES.common.disp_matrix([res_sqp.LS_count res_sqp.MPTP res_sqp.PPM;...
                          res_amv.LS_count res_amv.MPTP res_amv.PPM;...
                          res_cmv.LS_count res_cmv.MPTP res_cmv.PPM;...
                          res_hmv.LS_count res_hmv.MPTP res_hmv.PPM],...
                         {'SQP','AMV','CMV','HMV'},...
                         {'# func. call','MPTP_1','MPTP_2','PPM'})

%%
% Provide plot

[X,Y]=meshgrid(linspace(-4,4,100));
Z=reshape(g(Tinv([X(:) Y(:)])),size(X));
figure('Position',[200 200 500 500])
Colors=get(gca,'ColorOrder');
contour(X,Y,Z,[0 0],'Color',Colors(end,:))
hold on
u_MPP=T(res_sqp.MPTP);
plot(u_MPP(1),u_MPP(2),'s',...
    'MarkerFaceColor',Colors(1,:),'MarkerEdgeColor',Colors(1,:))

%%
% <html><a id="sensitivities"></a></html>
%% Sensitivities
% Here is ans example on how to compute sensitivities of the probabilistic
% performance measure. See <iform.html#sensitivities |iform| help> for 
% details on the options.

g=@(x,z)CODES.test.lin([x repmat(z,size(x,1),1)]);
T=@(x,mu)norminv(expcdf(x,mu));
Tinv=@(u,mu)expinv(normcdf(u),mu);

z=0;
mu=0.5;
delta=1e-3;

res_iform=CODES.reliability.iform(@(x)g(x,z),2,2,...
    'Tinv',@(x)Tinv(x,mu),'eps',1e-5,'gz',g,'z',z,...
    'Tinvtheta',Tinv,'T',T,'theta',mu);
res_iform_theta=CODES.reliability.iform(@(x)g(x,z),2,2,...
    'Tinv',@(x)Tinv(x,mu+delta),'eps',1e-5);
res_iform_z=CODES.reliability.iform(@(x)g(x,z+delta),2,2,...
    'Tinv',@(x)Tinv(x,mu),'eps',1e-5);

dGdmu=(res_iform_theta.PPM-res_iform.PPM)/delta;
dGdz=(res_iform_z.PPM-res_iform.PPM)/delta;

CODES.common.disp_matrix([dGdz res_iform.dPPMdz;dGdmu res_iform.dPPMdtheta],...
    {'dPPM/dz','dPPM/dtheta'},...
    {'FD','Analytical'})

%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_youn">
%   <span style="color:#005fce;">Youn et al. (2003)</span>: Youn, B. D.,
%   Choi, K. K., & Park, Y. H. (2003). <i>Hybrid Analysis Method for
%   Reliability-Based Design Optimization</i>. Journal of Mechanical
%   Design, 125(2), 221. <a
%   href="http://dx.doi.org/10.1115/1.1561042">DOI</a>
%   </li>
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
