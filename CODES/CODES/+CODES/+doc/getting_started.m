%% <CODES.html CODES Toolbox>: Getting Started
%
% Through a very simple example, this page showcases some of the key
% elements of the CODES toolbox.
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% A beam example
%
% <html><img src="beam.png" width=500px></html>
%
% Consider a simple cantilever beam  with a rectangular cross section. The
% goal of this example is to explicitly identify the region of the design
% space where the tip deflection of the beam is above 1 mm. This "explicit
% design space decomposition" is performed in a three dimensional space:
%
% * _b_: cross sectional width
% * _h_: cross sectional height
% * _P_: vertical tip loading
%
% The tip deflection (in mm) is given by:
%
% $$\frac{PL^3}{3EI}$$
%
% where the second moment of the area is:
%
% $$I=\frac{bh^3}{12}$$
%
% Although an analytical function is used, this problem is also
% representative of cases of expensive black-box functions (e.g., finite
% element code). 

tip_def=@(x)(x(:,3)*200^3)./(3*210e3*(x(:,1).*x(:,2).^3)/12);

%% Explicit Design Space Decomposition

g=@(x)1-tip_def(x);

%%
% The design variable ranges are:
%
% * _b_: 4 to 15 mm
% * _h_: 12 to 24 mm
% * _P_: 59 to 118 N
%
% For reference, plot the actual boundary g=0 which will be approximated in
% the subsequent steps:

lb_x=[4 12 59];
ub_x=[15 24 118];
[x,y,z]=meshgrid(linspace(lb_x(1),ub_x(1),100),...
                 linspace(lb_x(2),ub_x(2),100),...
                 linspace(lb_x(3),ub_x(3),100));
vals=reshape(g([x(:) y(:) z(:)]),size(x));
figure('Position',[200 200 500 500])
p=patch(isosurface(x,y,z,vals,0));
p.FaceColor='red';
p.EdgeColor='none';
grid on
view(34,30)
axis square
axis(reshape([lb_x;ub_x],1,6))
camlight
lighting gouraud
xlabel('$b$','interpreter','latex','fontsize',20)
ylabel('$h$','interpreter','latex','fontsize',20)
zlabel('$P$','interpreter','latex','fontsize',20)

%%
% Explicit Design Space Decomposition (EDSD) is performed using a Support
% Vector Machine (SVM) classifier. The first step is to obtain a design of
% experiments and build an initial SVM. The class of each sample needed for
% the training of SVM is obtained through the sign of the g function. If it
% is negative then it is considered "failure" or "infeasible". By default,
% the SVM kernel is Gaussian with parameter selected using the
% <Test_fit_svm_param_select.html#jaakkola_ref Jaakkola's technique>.

X=CODES.sampling.cvt(30,3,...
                   'lb',[4 12 59],...
                   'ub',[15 24 118]);       % 30 CVT samples in dimension 3
Y=g(X);                                     % Evaluate DOE
svm=CODES.fit.svm(X,Y,'UseParallel',true);  % Build an SVM and enable
                                            % parallel calculation
svm.isoplot('lb',[4 12 59],...
            'ub',[15 24 118],...
            'bcol','b',...
            'new_fig',true);                % Plot initial SVM
grid on
view(34,30)
axis square
axis(reshape([lb_x;ub_x],1,6))
xlabel('$b$','interpreter','latex','fontsize',20)
ylabel('$h$','interpreter','latex','fontsize',20)
zlabel('$P$','interpreter','latex','fontsize',20)

%%
% The initial boundary is iteratively refined through adaptive sampling.
% The <edsd.html EDSD> procedure relies on the successive addition of
% <mm.html max-min> and <anti_lock.html anti-locking> samples. Click
% on the previous links for details on the functions and their options.
% The following refinement uses 20 samples:

svm_col=CODES.sampling.edsd(g,svm,lb_x,ub_x,'iter_max',20,...
                          'conv',false,'display_EDSD',false);

%%
% Plot the final SVM after 20 adaptive samples in addition to the 30 from
% initial design of experiments:

svm_col{end}.isoplot('lb',[4 12 59],...
                     'ub',[15 24 118],...
                     'bcol','b',...
                     'new_fig',true);       % Plot initial SVM
grid on
view(34,30)
axis square
axis(reshape([lb_x;ub_x],1,6))
xlabel('$b$','interpreter','latex','fontsize',20)
ylabel('$h$','interpreter','latex','fontsize',20)
zlabel('$P$','interpreter','latex','fontsize',20)

%% Sensitivity analysis
% In many cases, it can be beneficial to perform a sensitivity analysis of
% the input variables of a model. The results of such analysis can
% typically be used to select features of a meta-model. The CODES toolbox
% offers three approaches: <corr_main.html correlation coefficients>,
% <dgsm.html derivative-based global sensitivity measures> and <sobol.html
% Sobol' indices>.

X=unifrnd(repmat(lb_x,1e4,1),repmat(ub_x,1e4,1));
Y=tip_def(X);
dY=CODES.common.grad_fd(tip_def,X,'vectorial',true);

%%
% Pearson correlation coefficient:

corr_coeff=CODES.sensitivity.corr(X,Y,'pie_plot',true);

%%
% Derivative-based sensitivity measures:

dgsm_values=CODES.sensitivity.dgsm(dY,'pie_plot',true);

%%
% Sobol' indices:

sobol_ind=CODES.sensitivity.sobol(tip_def,3,1e5,'lb',lb_x,'ub',ub_x,'vectorized',true,'bar_plot',true);

%% Reliability assessment
% The reliability assessment for structures and other mechanical design is
% an important aspect of computational design. The CODES toolbox includes
% four approaches: <mc.html crude Monte Carlo>, <form.html FORM>,
% <sorm.html SORM> and <subset.html subset simulations>.
%
% Let's assume for the purpose of this example, and to be consitent with
% the previous examples, that the three random variables are independent
% with the following marginal distributions:
% $$b\sim U(5,15)$$
% $$h\sim U(12,24)$$
% $$P\sim U(59,118)$$
% An appropriate inverse transform (required for FORM/SORM) is:

Tinv=@(u)unifinv(normcdf(u),repmat(lb_x,size(u,1),1),repmat(ub_x,size(u,1),1));

%%
% An appropriate sampling function, required for CMC/SubSim is:

sampler=@(N)unifrnd(repmat(lb_x,N,1),repmat(ub_x,N,1));

%%
% Appropriates marginals, required for SubSim, are:

PDFs=@(x)unifpdf(x,repmat(lb_x,size(x,1),1),repmat(ub_x,size(x,1),1));

%%
% The approximated/estimated probabilities of failure are:

res_form=CODES.reliability.form(g,3,'Tinv',Tinv);
disp(res_form)
res_sorm=CODES.reliability.sorm(g,3,'Tinv',Tinv);
disp(res_sorm)
res_mc=CODES.reliability.mc(g,3,'sampler',sampler,'vectorial',true);
disp(res_mc)
res_subsim=CODES.reliability.subset(g,3,'PDFs',PDFs,'sampler',sampler,'vectorial',true);
disp(res_subsim)

%%
% <html>
% Let us use this example to stress out the advantage of vectorizing limit
% state function, when possible, and setting <span
% class="string">'vectorized'</span> to <tt>true</tt> when using
% reliability assessment techniques:
% </html>

tic;
CODES.reliability.mc(g,3,'sampler',sampler);
disp(['Not vectorized: ' CODES.common.time(toc)])
tic;
CODES.reliability.mc(g,3,'sampler',sampler,'vectorial',true);
disp(['Vectorized: ' CODES.common.time(toc)])

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
