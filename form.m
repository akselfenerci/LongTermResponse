
clear all
close all
clc

dbstop if error


%%

% variables are U, sigmau, sigmaw and Xd

% initial point
xini = [15, 3, 2, 0.5];

% rosenblatt transform

% U, mean speed
u1 = norminv(logncdf(xini(1),1.0967,0.4894));

% sigma u, turbulence
u2_old = norminv(logncdf(xini(2),0.122+0.039*xini(1),0.3159));

rhoY = 0.8148;
sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
[ fjoint_handle ] = joint_pdf_lognormal( sigma_dash, rhoY );

ints1 = 0.01:0.1:10;
ints2 = 0.01:0.1:xini(2);

[int1,int2] = meshgrid(ints1,ints2);

funcondturb = @(x1,x2) fjoint_handle(x1,x2,xini(1));
fcondturb = arrayfun(funcondturb,int1,int2);

Fx2 = trapz(ints2,trapz(ints1,fcondturb,2),1);
u2 = norminv(Fx2);

% sigma w, turbulence vertical
rhoY = 0.8148;
sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
[ fjoint_handle ] = joint_pdf_lognormal( sigma_dash, rhoY );
cond_dist = @(x) fjoint_handle(xini(2),x,xini(1));
ints = 0.01:0.1:xini(3);

Fx3 = trapz(ints,arrayfun(cond_dist,ints))/lognpdf(xini(2),0.122+0.039*xini(1),0.3159)/logncdf(xini(1),1.0967,0.4894);
u3 = norminv(Fx3);

% Xd, short-term extreme response
load('RSmodel');
Tshort = 600;
[std] = predict(lmSTD,xini(1:3));
[stddot] = predict(lmSTDdot,xini(1:3));
std(std<0) = 1e-5;
stddot(stddot<0) = 1e-5;
[ Fx_d ] = short_term_extreme( std,stddot,Tshort,xini(4) );
u4 = norminv(Fx_d);


u = [u1 u2 u3 u4];




%%

d1 = 0.05;
d2 = 0.05;
d3 = 0.1;
d4 = 0.1;

d = [d1 d2 d3 d4];

% Jacobian

FFx1 = @(x1) logncdf(x1,1.0967,0.4894);
FFx2 = @(x1,x2) logncdf(x2,0.122+0.039*x1,0.3159);
FFx3 = @(x1,x2,x3) trapz(0.01:0.1:x3,arrayfun(cond_dist,0.01:0.1:x3))/lognpdf(x2,0.122+0.039*x1,0.3159);
FFx4 = @(x1,x2,x3,x4)  short_term_extreme( predict(lmSTD,[x1 x2 x3]),predict(lmSTDdot,[x1 x2 x3]),Tshort,x4 );

FFx = {FFx1, FFx2, FFx3, FFx4};

for i = 1:4
    for j = 1:4
        
        if i>= j 
            
            xvec = [xini(j) xini(j)+d(j)];
            
            switch i
                case 1
                    gradFx = (FFx{i}(xvec(2)) - FFx{i}(xvec(1)))/d(j);
                case 2
                    gradFx = (FFx{i}(xini(1),xvec(2)) - FFx{i}(xini(1),xvec(1)))/d(j);       
                case 3
                    gradFx = (FFx{i}(xini(1),xini(2),xvec(2)) - FFx{i}(xini(1),xini(2),xvec(1)))/d(j);                   
                case 4
                    gradFx = (FFx{i}(xini(1),xini(2),xini(3),xvec(2)) - FFx{i}(xini(1),xini(2),xini(3),xvec(1)))/d(j); 
            end
            
            JJ(i,j) = 1/(normpdf(u(i)))*gradFx;
            
        end
    end
end


% gradient of the limit state function in the u-space
Gx = [0 0 0 1]';
gu = inv(JJ)*Gx;






































