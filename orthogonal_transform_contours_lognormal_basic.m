clearvars
close all
dbstop if error

%%
Ftarget = 1-1/(365*24*6);
beta_target = norminv(Ftarget);

u1vals = -beta_target:0.1:beta_target;
u2vals = sqrt(beta_target.^2 - u1vals.^2);

uu = [u1vals(:),u2vals(:); u1vals(:),-u2vals(:)];

figure; plot(uu(:,1),uu(:,2),'b*'); hold on;


% orthogonal
[ covX,covY ] = covX_given_xx1( 20 );
mu_dash1 = @(u) 0.122+0.039*u;
mu_dash2 = @(u) -0.657+0.03*u;
mu_dash = [mu_dash1(20) mu_dash2(20)];


[A,d] = eig(covY);
TT = inv(sqrt(d))'*A';
xx = exp(TT\uu' + mu_dash');


xspace = figure; plot(xx(1,:),xx(2,:),'b*'); hold on;



% Rosenblatt
rhoY = 0.8148;
sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
% v = sqrt((exp(sigma_dash.^2)-1).*exp(2.*mu_dash+sigma_dash));
% m = exp(mu_dash+sigma_dash./2);
% covX = log(rhoY*v(1)*v(2)/(m(1)*m(2))+1);
% rhoX = covX/sigma_dash(1)/sigma_dash(2);


xR1 = arrayfun(@(x) icdf('Lognormal',x,mu_dash(1),sigma_dash(1)), normcdf(uu(:,1)));

[ fjoint_handle ] = joint_pdf_lognormal( sigma_dash, rhoY );

for i = 1:length(xR1)
    
    ff = @(x) fjoint_handle(xR1(i),x,20);
    Fsw = @(x) trapz(0.001:0.001:x,arrayfun(ff,0.001:0.001:x))/lognpdf(xR1(i),mu_dash(1),sigma_dash(1));
    Fminimize = @(x) abs(Fsw(x) - normcdf(uu(i,2)));
    
    upper = 5;
    fval = 1;
    while fval > 0.01
        %     [xx(3),fval] = fminbnd(Fminimize,0,upper,options);
        [xR2(i),fval] = fminbnd(Fminimize,0,upper);
        upper = upper - 0.5;
    end
    
end

figure(xspace); plot(xR1,xR2,'rx'); hold on;




% Rosenblatt reverse
rhoY = 0.8148;
sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;

xRR2 = arrayfun(@(x) icdf('Lognormal',x,mu_dash(2),sigma_dash(2)), normcdf(uu(:,2)));

[ fjoint_handle ] = joint_pdf_lognormal( sigma_dash, rhoY );

for i = 1:length(xRR2)
    
    ff = @(x) fjoint_handle(x,xRR2(i),20);
    Fsw = @(x) trapz(0.001:0.001:x,arrayfun(ff,0.001:0.001:x))/lognpdf(xRR2(i),mu_dash(2),sigma_dash(2));
    Fminimize = @(x) abs(Fsw(x) - normcdf(uu(i,1)));
    
%     options = optimset('TolX',1e-8,'TolFun',1e-8,'Display','iter','FunValCheck','on','MaxFunEvals',500,'MaxIter',500,'PlotFcns','optimplotfval');

    upper = 12;
    fval = 1;
    while fval > 0.1
        
%           [xRR1(i),fval] = fminbnd(Fminimize,0,upper,options);
        [xRR1(i),fval] = fminbnd(Fminimize,0,upper);
        upper = upper - 1;
        if upper < 0.01
            xRR1(i) = nan;
            break
        end
    end
    
end

figure(xspace); plot(xRR1,xRR2,'mo'); hold on;
