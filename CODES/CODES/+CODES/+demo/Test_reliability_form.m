%% <demo.html Examples> / <demo_reliability.html Reliability assessment> / form
% This file is a complete demo of the capability of the |form| function
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
% The documentation for the |form| function can be found <form.html here>.
%
%% Set rng
% Set random number generator seed:
rng(0)

%% Simple linear example
% Compute the FORM $\hat{P}_f$ on a simple linear example:

g=@CODES.test.lin;
res_form=CODES.reliability.form(g,2);

%%
% Compare to MC estimate

res_mc=CODES.reliability.mc(g,2);
CODES.common.disp_matrix([res_form.beta res_mc.beta;res_form.Pf res_mc.Pf],...
    {'Beta','Pf'},{'FORM','MC'})

%%
% Plot the limit state and the MPP

figure('Position',[200 200 500 500])
[X,Y]=meshgrid(linspace(-4,4,100));
Z=reshape(g([X(:) Y(:)]),size(X));
Z_pdf=reshape(prod(normpdf([X(:) Y(:)]),2),size(X));
Colors=get(gca,'ColorOrder');
contour(X,Y,Z_pdf)
hold on
contour(X,Y,Z,[0 0],'Color',Colors(end,:))
caxis([min(Z_pdf(:)) max(Z_pdf(:))])
plot(res_form.MPP(1),res_form.MPP(2),'s',...
    'MarkerEdgeColor',Colors(4,:),...
    'MarkerFaceColor',Colors(4,:))
axis equal
leg=legend('$\mathbf{f}_{\mathbf{X}}$','$g(\mathbf{X})=0$','$MPP$',...
    'location','NorthWest');
set(leg,'interpreter','latex')

%% Exponential distribution
% Same example but the variable are exponentials. We use iso-probabilistic
% transformation:

T=@(x)norminv(expcdf(x,0.5));
Tinv=@(u)expinv(normcdf(u),0.5);
res_form=CODES.reliability.form(g,2,'Tinv',Tinv);

%%
% Compare with Monte Carlo estimate

res_mc=CODES.reliability.mc(g,2,'sampler',@(N)exprnd(0.5,N,2));
CODES.common.disp_matrix([res_form.beta res_mc.beta;res_form.Pf res_mc.Pf],...
    {'Beta','Pf'},{'FORM','MC'})

%%
% Plot the limit state and the MPP

figure('Position',[200 200 500 500])
[X,Y]=meshgrid(linspace(0,5,100));
[Xu,Yu]=meshgrid(linspace(-4,4,100));
Z=reshape(g([X(:) Y(:)]),size(X));
Zu=reshape(g(T([Xu(:) Yu(:)])),size(X));
Z_pdf=reshape(prod(exppdf([X(:) Y(:)],0.5),2),size(X));
Zu_pdf=reshape(prod(normpdf([Xu(:) Yu(:)]),2),size(X));
Colors=get(gca,'ColorOrder');
contour(X,Y,Z_pdf)
hold on
contour(X,Y,Z,[0 0],'Color',Colors(end,:))
caxis([min(Z_pdf(:)) max(Z_pdf(:))])
plot(res_form.MPP(1),res_form.MPP(2),'s',...
    'MarkerEdgeColor',Colors(4,:),...
    'MarkerFaceColor',Colors(4,:))
axis equal
leg=legend('$\mathbf{f}_{\mathbf{X}}$','$g(\mathbf{X})=0$','$MPP$',...
    'location','NorthWest');
set(leg,'interpreter','latex')
title('X Space')

figure('Position',[200 200 500 500])
contour(Xu,Yu,Zu_pdf)
hold on
contour(Xu,Yu,Zu,[0 0],'Color',Colors(end,:))
caxis([min(Zu_pdf(:)) max(Zu_pdf(:))])
MPPu=Tinv(res_form.MPP);
plot(MPPu(1),MPPu(2),'s',...
    'MarkerEdgeColor',Colors(4,:),...
    'MarkerFaceColor',Colors(4,:))
axis equal
leg=legend('$\phi$','$g(\mathbf{X})=0$','$MPP$','location','NorthWest');
set(leg,'interpreter','latex')
title('U Space (standard normal)')

%% Compare SQP and HL-RF

res_sqp=CODES.reliability.form(g,2,'Tinv',Tinv,'solver','sqp');
res_RFHL=CODES.reliability.form(g,2,'Tinv',Tinv,'solver','hl-rf');
CODES.common.disp_matrix([res_sqp.LS_count res_RFHL.LS_count],...
    {'# of LS calls'},{'SQP','HL-RF'})

%% Providing gradient of the limit state function

res_sqp=CODES.reliability.form(g,2,'Tinv',Tinv,'solver','sqp');
res_sqp_grad=CODES.reliability.form(g,2,'Tinv',Tinv,'solver','sqp',...
    'LS_grad',true);
res_hlrf=CODES.reliability.form(g,2,'Tinv',Tinv,'solver','hl-rf');
res_hlrf_grad=CODES.reliability.form(g,2,'Tinv',Tinv,'solver','hl-rf',...
    'LS_grad',true);
CODES.common.disp_matrix([res_sqp.LS_count res_sqp_grad.LS_count;...
    res_hlrf.LS_count res_hlrf_grad.LS_count],{'SQP','HL-RF'},...
    {'FD','Grad'})

%% Compare RIA algorithm
% Compute MPP using different algorithm on semi-complex function

g_gen=@(x,alpha)x(:,1)-1.7*x(:,2)+alpha*(x(:,1)+1.7*x(:,2)).^2+5;
g=@(x)g_gen(x,0.015);

form_sqp=CODES.reliability.form(g,2,'solver','sqp');
form_hl_rf=CODES.reliability.form(g,2,'solver','hl-rf');
form_ihl_rf=CODES.reliability.form(g,2,'solver','ihl-rf');
form_jhl_rf=CODES.reliability.form(g,2,'solver','jhl-rf');

CODES.common.disp_matrix([form_sqp.LS_count form_sqp.MPP;...
                          form_hl_rf.LS_count form_hl_rf.MPP;...
                          form_ihl_rf.LS_count form_ihl_rf.MPP;...
                          form_jhl_rf.LS_count form_jhl_rf.MPP],...
    {'SQP','HL-RF','iHL-RF','jHL-RF'},{'# func. call','X1','X2'})

figure('Position',[200 200 500 500])
Colors=get(gca,'ColorOrder');
[X,Y]=meshgrid(linspace(-4,4,100));
Z=reshape(g([X(:) Y(:)]),size(X));
contour(Xu,Yu,Zu_pdf)
hold on
contour(X,Y,Z,[0 0],'Color',Colors(end,:))
caxis([min(Zu_pdf(:)) max(Zu_pdf(:))])
plot(form_sqp.MPP(1),form_sqp.MPP(2),'s',...
    'MarkerFaceColor',Colors(4,:),...
    'MarkerEdgeColor',Colors(4,:));

%%
% On a complex function

g=@(x)g_gen(x,15);

form_sqp=CODES.reliability.form(g,2,'solver','sqp');
form_hl_rf=CODES.reliability.form(g,2,'solver','hl-rf');
form_ihl_rf=CODES.reliability.form(g,2,'solver','ihl-rf');
form_jhl_rf=CODES.reliability.form(g,2,'solver','jhl-rf');

CODES.common.disp_matrix([form_sqp.LS_count form_sqp.MPP;...
                          form_hl_rf.LS_count form_hl_rf.MPP;...
                          form_ihl_rf.LS_count form_ihl_rf.MPP;...
                          form_jhl_rf.LS_count form_jhl_rf.MPP],...
    {'SQP','HL-RF','iHL-RF','jHL-RF'},{'# func. call','X1','X2'})

figure('Position',[200 200 500 500])
Colors=get(gca,'ColorOrder');
[X,Y]=meshgrid(linspace(-4,4,100));
Z=reshape(g([X(:) Y(:)]),size(X));
contour(Xu,Yu,Zu_pdf)
hold on
contour(X,Y,Z,[0 0],'Color',Colors(end,:))
caxis([min(Zu_pdf(:)) max(Zu_pdf(:))])
plot(form_sqp.MPP(1),form_sqp.MPP(2),'s',...
    'MarkerFaceColor',Colors(4,:),...
    'MarkerEdgeColor',Colors(4,:));

%%
% <html><a id="sensitivities"></a></html>
%% Sensitivities
% Here is ans example on how to compute sensitivities of the approximated
% probability of failure. See <form.html#sensitivities |form| help> for
% details on the options.

g=@(x,z)CODES.test.lin([x repmat(z,size(x,1),1)]);
T=@(x,mu)norminv(expcdf(x,mu));
Tinv=@(u,mu)expinv(normcdf(u),mu);

z=0;
mu=0.5;
delta=1e-3;

res_form=CODES.reliability.form(@(x)g(x,z),2,'Tinv',@(x)Tinv(x,mu),...
    'eps',1e-5,'gz',g,'z',z,'T',T,'theta',mu);
res_form_theta=CODES.reliability.form(@(x)g(x,z),2,...
    'Tinv',@(x)Tinv(x,mu+delta),'eps',1e-5);
res_form_z=CODES.reliability.form(@(x)g(x,z+delta),2,...
    'Tinv',@(x)Tinv(x,mu),'eps',1e-5);

dbetadz=(res_form_z.beta-res_form.beta)/delta;
dPfdz=(res_form_z.Pf-res_form.Pf)/delta;
dbetadtheta=(res_form_theta.beta-res_form.beta)/delta;
dPfdtheta=(res_form_theta.Pf-res_form.Pf)/delta;

CODES.common.disp_matrix([dPfdz res_form.dPfdz;dbetadz res_form.dbetadz;...
    dPfdtheta res_form.dPfdtheta;dbetadtheta res_form.dbetadtheta],...
    {'dPf/dz','dbeta/dz','dPf/dtheta','dbeta/dtheta'},...
    {'FD','Analytical'})

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
