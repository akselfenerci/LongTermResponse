clearvars
close all
dbstop if error

% normally distributed variables with covariance matrix

mu = [0 0];
covI = [1 0.5; 0.5 1 ];

x = mvnrnd(mu,covI,1000);
covX = cov(x);

figure; plot(x(:,1), x(:,2),'.');

% y = exp(x);

% figure; plot(y(:,1), y(:,2),'.');
% covY = cov(y);

% mm = exp(mu+diag(covI)./2);
% 
% for i = 1:2
%     for j = 1:2
%         covX_from_Y(i,j) = log(covY(i,j)/mm(i)/mm(j)+1);
%     end
% end


% transform normally distributed variables to u-space

[A,d] = eig(covX);

TT = inv(sqrt(d))'*A';

U = TT*x';
corrcoef(U')
mean(U')
CU = TT*covX*TT'
cov(U')
figure; plot(U(1,:), U(2,:),'.');


mvncdf((TT*x(1,:)')')

xx = inv(TT)*U;
cov(xx')
figure; plot(xx(1,:),xx(2,:),'.');
hold on;
plot(x(:,1),x(:,2),'.');

betaU = sqrt(sum(abs(U).^2));


% check if this is the same as Rosenblatt

% first normal variables

% [ fjoint_norm ] = @(x1,x2) mvnpdf([x1 x2], mu, covX);
% x2dummy = -5:0.1:5;
% fcondnorm = @(x) trapz(x2dummy,arrayfun(@(y) fjoint_norm(x,y), x2dummy));

% x1dummy = -5:0.1:5;
% for i = 1:length(x1dummy)
%     ff(i) = fcondnorm(x1dummy(i));
% end
% figure; plot(x1dummy, ff);
% trapz(x1dummy,ff)

% x1dummy = -5:0.1:x(1,1);
% Fsu = trapz(x1dummy, arrayfun(fcondnorm,x1dummy));
% u1x = norminv(Fsu);


% Rosenblatt
for i = 1:size(x,1)

    Fsu_matlab = normcdf(x(i,1), mu(1), sqrt(covX(1,1)));
    u1x(i) = norminv(Fsu_matlab);

    ff  = @(x2) mvnpdf([x(i,1) x2], mu, covX);
    x2dummy = -6:0.01:x(i,2);
    Fsw(i) = trapz(x2dummy,arrayfun(ff,x2dummy))./normpdf(x(i,1), mu(1), sqrt(covX(1,1)));
    u2x(i) = norminv(Fsw(i));

end


% Rosenblatt reverse order
for i = 1:size(x,1)

    FswR = normcdf(x(i,2), mu(2), sqrt(covX(2,2)));
    u2xR(i) = norminv(FswR);

    ff  = @(x1) mvnpdf([x1 x(i,2)], mu, covX);
    x1dummy = -6:0.01:x(i,1);
    Fsw(i) = trapz(x1dummy,arrayfun(ff,x1dummy))./normpdf(x(i,2), mu(2), sqrt(covX(2,2)));
    u1xR(i) = norminv(Fsw(i));

end

figure; plot(u1x,u2x,'.');
corrcoef([u1x;u2x]')
cov([u1x;u2x]')
mean(u1x)
mean(u2x)

figure; plot(u1xR,u2xR,'.'); hold on;
plot(u1x,u2x,'.');
corrcoef([u1xR;u2xR]')
cov([u1xR;u2xR]')
mean(u1xR)
mean(u2xR)

betau1 = sqrt(sum(abs([u1x;u2x]).^2));
betauR = sqrt(sum(abs([u1xR;u2xR]).^2));

figure;
plot(betaU,'o'); hold on;
plot(betau1,'x');
plot(betauR,'^');

figure; 
plot(u1x,'o'); hold on;
plot(u1xR,'x');
plot(U(1,:),'^');

figure;
plot(mvncdf(U'),'x'); hold on;
plot(mvncdf(x,mu,covI),'^'); hold on;
plot(mvncdf([u1x;u2x]'),'o'); hold on;
plot(mvncdf([u1xR;u2xR]'),'sq'); hold on;
plot(normcdf(-betaU),'d'); hold on;

figure;
plot(mvnpdf(U'),'x'); hold on;
plot(mvnpdf(x,mu,covI),'^'); hold on;
plot(mvnpdf([u1x;u2x]'),'o'); hold on;
plot(mvnpdf([u1xR;u2xR]'),'sq'); hold on;
% plot(normpdf(-betaU),'d'); hold on;

%%

% check probability
mvncdf([u1x(1) u2x(1)])

mvncdf(x(1,:),mu,covI)

mvncdf(U(:,1))

figure; plot(U(1,:), U(2,:),'.');
hold on;
plot(u1x,u2x,'.');



figure; plot(u1x,mvncdf([u1x; u2x]'),'o');
hold on;
plot(U(1,:),mvncdf(U'),'x')
figure; plot(u2x,mvncdf([u1x; u2x]'),'o');
hold on;
plot(U(2,:),mvncdf(U'),'x')


figure; plot(u1x,mvncdf([u1x; u2x]' ),'o');
hold on;
plot(u1x,mvncdf(x,mu,covX),'x');
figure; plot(u2x,mvncdf([u1x; u2x]' ),'o');
hold on;
plot(u2x,mvncdf(x,mu,covX),'x');

figure; plot(u1x,mvncdf([u1x; u2x]' )); hold on; plot(mvncdf(x,mu,covX));

figure; plot(U(1,:),mvncdf(U'),'o');
hold on;
plot(U(1,:),mvncdf(x,mu,covX),'x');
figure; plot(U(2,:),mvncdf(U'),'o');
hold on;
plot(U(2,:),mvncdf(x,mu,covX),'x');



figure; 
plot(U(1,:), U(2,:),'o');
hold on;
plot(u1x,u2x,'x');





%%
% 
% [ fjoint_handle ] = joint_pdf_lognormal_generic( mu,[sqrt(covY(1,1)) sqrt(covY(2,2))], covY(1,2)/mm(1)/mm(2) );
% 
% ydummy = 0.01:0.01:10;
% fcond = @(x) trapz(ydummy,arrayfun(@(y) fjoint_handle(x,y), ydummy));
% xdummy = 0.01:0.01:x(1,1);
% Fsu = trapz(xdummy, arrayfun(fcond,xdummy));
% u1 = norminv(Fsu);