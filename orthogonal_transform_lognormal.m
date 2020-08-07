clearvars
close all
dbstop if error


% normally distributed variables X with covariance matrix

mu = [0 0];
covI = [1 0.5; 0.5 1 ];

x = mvnrnd(mu,covI,1000);
covX = cov(x);

figure; plot(x(:,1), x(:,2),'.');

% lognormally distributed variables Y  

y = exp(x);

figure; plot(y(:,1), y(:,2),'.');

covY = cov(y);

mm = exp(mu+diag(covI)./2);

for i = 1:2
    for j = 1:2
        covX_from_Y(i,j) = log(covY(i,j)/mm(i)/mm(j)+1);
    end
end


% transform

[A,d] = eig(covX);

TT = inv(sqrt(d))'*A';

U = TT*x';
corrcoef(U')
mean(U')
CU = TT*covX*TT'
cov(U')
figure; plot(U(1,:), U(2,:),'.');

% transform lognormal
Ulog = TT*log(y)';

figure; plot(Ulog(1,:), Ulog(2,:),'.');

