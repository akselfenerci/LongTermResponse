
clearvars



mu_dash1 = @(u) 0.122+0.039*u;
mu_dash2 = @(u) -0.657+0.03*u;

sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;


Mu = [mu_dash1(20) mu_dash2(20)];

rhox = 0.8;

cov = [sigma_dash(1)^2 rhox*sigma_dash(1)*sigma_dash(2);  rhox*sigma_dash(1)*sigma_dash(2)  sigma_dash(2)^2];

normdistvars = mvnrnd( Mu , cov , 1000 );

lognormdistvars = exp(normdistvars);

std(lognormdistvars)

mean(lognormdistvars)

coefmatrix = corrcoef(lognormdistvars);
rhoY = coefmatrix(1,2);

v = sqrt((exp(sigma_dash.^2)-1).*exp(2.*Mu+sigma_dash));
covY = [rhoY*v(1)^2 rhoY*v(1)*v(2); rhoY*v(1)*v(2) rhoY*v(2)];
m = exp(Mu+sigma_dash./2);

for i = 1:2
    for j = 1:2
        covX(i,j) = log(covY(i,j)/(m(i)*m(j))+1);
    end
end

for i = 1:2
    for j = 1:2
        covX2(i,j) = log(coefmatrix(i,j)*sqrt(exp((sigma_dash(i)^2)-1))*sqrt(exp((sigma_dash(j)^2)-1))+1);
    end
end


covX(1,2)/sigma_dash(1)/sigma_dash(2)

