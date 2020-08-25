function [ covX,covY ] = covX_given_xx1( xx1 )


mu_dash1 = @(u) 0.122+0.039*u;
mu_dash2 = @(u) -0.657+0.03*u;
rhoY = [1 0.8148; 0.8148 1];
sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;

mu_dash = [mu_dash1(xx1) mu_dash2(xx1)];
m = exp(mu_dash+sigma_dash./2);

for i = 1:2
    for j = 1:2
        covY(i,j) = sigma_dash(i)*sigma_dash(j)*rhoY(i,j);
    end
end

for i = 1:2
    for j = 1:2
        covX(i,j) = log(covY(i,j)/(m(i)*m(j))+1);
    end
end

end

