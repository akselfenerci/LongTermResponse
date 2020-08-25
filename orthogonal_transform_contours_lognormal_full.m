clearvars
% close all
dbstop if error

%%
Ftarget = 1-1/(4*365*24*6);
beta_target = norminv(Ftarget);

u1vals = -beta_target:0.1:beta_target;
u2vals = -beta_target:0.1:beta_target;

[uu1,uu2,uu3] = sphere(100);
uu1 = uu1*beta_target;
uu2 = uu2*beta_target;
uu3 = uu3*beta_target;
figure; 
mesh(uu1,uu2,uu3);


% first rosenblatt
xx1 = arrayfun(@(x) icdf('Lognormal',x,1.0967,0.4894),arrayfun(@normcdf,uu1));


% orthogonal transform
[~,covYcell] = cellfun(@covX_given_xx1, num2cell(xx1),'UniformOutput',0);

[A,d] = cellfun(@eig,covYcell,'UniformOutput',0);
TT = cellfun(@(x,y) sqrt(x)'\y', d, A,'UniformOutput',0);


x2x3 = cellfun(@(x,y,z) x\[y z]', TT, num2cell(uu2), num2cell(uu3) ,'UniformOutput',0);

mu_dash2 = @(u) 0.122+0.039*u;
mu_dash3 = @(u) -0.657+0.03*u;
mu_dash2 = cellfun(@(x) mu_dash2(x), num2cell(xx1),'UniformOutput',0);    
mu_dash3 = cellfun(@(x) mu_dash3(x), num2cell(xx1),'UniformOutput',0);    


xx2 = cell2mat(cellfun(@(x,y) exp(x(1) + y), x2x3,mu_dash2,'UniformOutput',0));
xx3 = cell2mat(cellfun(@(x,y) exp(x(2) + y), x2x3,mu_dash3,'UniformOutput',0));

figure; 
mesh(xx1,xx2,xx3)






% rosenblatt


    