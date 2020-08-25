clearvars
close all
dbstop if error


mu = [0 0];
covI = [1 0.5; 0.5 1 ];

% x = mvnrnd(mu,covI,1000);

% orthogonal transform

[A,d] = eig(covI);
TT = inv(sqrt(d))'*A';

beta_target = 4.5;
u1vals = -4.5:0.01:4.5;
u2vals = sqrt(beta_target.^2 - u1vals.^2);

uu = [u1vals(:),u2vals(:); u1vals(:),-u2vals(:)];

figure; plot(uu(:,1),uu(:,2),'b*'); hold on;

xx = inv(TT)*uu';

xspace = figure; plot(xx(1,:),xx(2,:),'b*'); hold on;


% rosenblatt

for i = 1:size(uu,1)
    xR1(i) = norminv(normcdf(uu(i,1)), mu(1), sqrt(covI(1,1))); 
    
    ff  = @(x2) mvnpdf([xR1(i) x2], mu, covI);
    Fsw = @(x) trapz(-5:0.01:x,arrayfun(ff,-5:0.01:x))/normpdf(xR1(i), mu(1), sqrt(covI(1,1)));
    Fminimize = @(x) abs(Fsw(x) - normcdf(uu(i,2)));
    
%     options = optimset('TolX',1e-8,'TolFun',1e-8,'Display','iter','FunValCheck','on','MaxFunEvals',500,'MaxIter',500,'PlotFcns','optimplotfval');
    options = optimset('TolX',1e-8,'TolFun',1e-8);
    
    upper = 5;
    fval = 1;
    while fval > 0.01
        [xR2(i),fval] = fminbnd(Fminimize,-5,upper,options);
        upper = upper - 0.5;
    end
    
    figure(xspace);
    hold on;
    plot(xR1(i),xR2(i), 'ro');
end


    