
load('settings.mat');


wind_input.z = 60;
wind_input.U = 30;
wind_input.sigmau = 5;
wind_input.sigmaw = 2.5;

[ std,stddot ] = short_term_response( settings,wind_input );

Tshort = 600;
x = 0.5;

[ Fx_d ] = short_term_extreme( std,stddot,Tshort,x );


% short-term extreme distribution
c = 1;
for i = 0.01:0.01:2
    
    [ Fx_d(c) ] = short_term_extreme( std,stddot,Tshort,i );
    x_axis(c) = i;
    c = c+1;
end

figure; plot(x_axis,Fx_d);

% joint pdf of turbulence

mu_dash(1) = 0.122+0.039*wind_input.U;
mu_dash(2) = -0.657+0.03*wind_input.U;
sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
rhoY = 0.8148;
y = [wind_input.sigmau wind_input.sigmaw];


y1 = 0.1:0.1:10;
y2 = 0.05:0.05:3;

[Xplot, Yplot] = meshgrid(y1,y2);


for i = 1:length(y1)
    for j = 1:length(y2)
        
        [ fturb_joint(j,i) ] = joint_pdf_turbulence( [Xplot(j,i),Yplot(j,i)], mu_dash, sigma_dash, rhoY );
        
    end
end

figure;
mesh(Xplot,Yplot,real(fturb_joint));
view([1.3 1 2.2]);
h = gca;
h.XLabel.String = '\sigma_{u} (m/s)';
h.YLabel.String = '\sigma_{w} (m/s)';
h.ZLabel.String = 'Prob. density';

trapz(log(y2),trapz(log(y1),fturb_joint,2),1)

trapz(y2,trapz(y1,fturb_joint,2),1)



% Joint pdf of all environmental parameters


Uvals = 0.5:0.5:20;
sigmauvals = 0.1:0.1:15;
sigmawfix = 2;


turb = [sigmauvals' repmat(sigmawfix,[length(sigmauvals),1])];
turbcell = mat2cell(turb,[ones(1,length(sigmauvals))], [2]);

turbpdf = cellfun(@(x) joint_pdf_turbulence(x, mu_dash, sigma_dash, rhoY) , turbcell);


[TurbPDF, Yplot] = meshgrid(turbpdf,Uvals);

[Xplot, ~] = meshgrid(sigmauvals,Uvals);

% joint_full_env = TurbPDF.*wblpdf(Yplot,1.4063,0.8616);

joint_full_env = TurbPDF.*lognpdf(Yplot,1.0967,0.4894);

figure;
mesh(Xplot,Yplot,real(joint_full_env));
view([1.3 1 2.2]);
h = gca;
h.XLabel.String = '\sigma_{u} (m/s)';
h.YLabel.String = 'U (m/s)';
h.ZLabel.String = 'Prob. density';

resp = 0.8;

LTfun = @(x,y,z) LT_int(x,y,z,resp);

dbstop if error

% dummy = integral3(LTfun,0,10,0,4,0,2)


%%

Uint = 1:5:40;
sigmauint = 0:1:10;
sigmawint = 0:0.5:3;

flt_int = 0;
resp = 0.001;

for i = 1:length(Uint)-1
    
    for j = 1:length(sigmauint)-1
        
        for k = 1:length(sigmawint)-1
            
            int(i,j,k) = LT_int( Uav,sigmauav,sigmawav,resp );
            
        end
    end
end



%% approximate the short term response with a response surface

Uvals = 1:1:40;
sigmauvals = 0:0.5:10;
sigmawvals = 0:0.5:6;

load('settings.mat');

wind_input.z = 60;


for i = 1:length(Uvals)
    
    wind_input.U = Uvals(i);
    
    for j = 1:length(sigmauvals)
        wind_input.sigmau = sigmauvals(j);
        
        for k = 1:length(sigmawvals)
            
            wind_input.sigmaw = sigmawvals(k);
            
            [ST_resp_std(i,j,k), ST_resp_stddot(i,j,k)] = short_term_response( settings,wind_input );
            
        end
    end
end

save('ST_response','ST_resp_std','ST_resp_stddot');



[X,Y,Z] = meshgrid(sigmauvals,Uvals,sigmawvals);

sz = size(X);
product = 1;
for i = 1:length(sz)
    product = product*sz(i);
end
X = reshape(X,[product,1]);
Y = reshape(Y,[product,1]);
Z = reshape(Z,[product,1]);
ST_resp_std_vec = reshape(ST_resp_std, [product,1]);
ST_resp_stddot_vec = reshape(ST_resp_stddot, [product,1]);

tbl = table(X,Y,Z,real(ST_resp_std_vec),'VariableNames',{'U','sigma_u','sigma_w','Resp_std'});
tbldot = table(X,Y,Z,real(ST_resp_stddot_vec),'VariableNames',{'U','sigma_u','sigma_w','Resp_stddot'});

% lmSTD = fitlm(tbl,'Resp_std~U+sigma_u+sigma_w','modelspec','quadratic');
% lmSTDdot = fitlm(tbl,'Resp_stddot~U+sigma_u+sigma_w','modelspec','quadratic');

lmSTD = fitlm([X Y Z],real(ST_resp_std_vec) ,'quadratic');
lmSTDdot = fitlm([X Y Z],real(ST_resp_stddot_vec) ,'quadratic');

[ypred,yci] = predict(lmSTD,[50 8 4]);

save('RSmodel','lmSTD','lmSTDdot');



%% full long term with response surface


Uvals = 1:1:40;
sigmauvals = 0.1:0.5:10;
sigmawvals = 0.1:0.5:6;

[X,Y,Z] = meshgrid(sigmauvals,Uvals,sigmawvals);

sz = size(X);
product = 1;
for i = 1:length(sz)
    product = product*sz(i);
end

% X = reshape(X,[product,1]);
% Y = reshape(Y,[product,1]);
% Z = reshape(Z,[product,1]);

resp = 0.8;
LTfun = @(x,y,z) LTint_RSM(x,y,z,resp,lmSTD,lmSTDdot);

ints = arrayfun(LTfun, X,Y,Z);

out = trapz(Uvals,trapz(sigmauvals,trapz(sigmawvals,ints,3),2),1);






%% get the CDF of the long term extreme

Uvals = 1:1:40;
sigmauvals = 0.1:0.5:10;
sigmawvals = 0.1:0.5:6;

sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
rhoY = 0.8148;

[X,Y,Z] = meshgrid(sigmauvals,Uvals,sigmawvals);

y_cell = cellfun(@(x,y) [x,y], num2cell(X), num2cell(Z),'UniformOutput',0);

mu_dash_cell = cellfun(@(x,y) [x,y], num2cell(0.122+0.039*Y), num2cell(-0.657+0.03*Y),'UniformOutput',0);
U_cell = num2cell(Y);

fun_full_env = @(y_fun,mu_dash_fun,u_fun) joint_pdf_turbulence( y_fun, mu_dash_fun, sigma_dash, rhoY )*lognpdf(u_fun,1.0967,0.4894);

joint_full_env = cellfun(fun_full_env, y_cell,mu_dash_cell, U_cell);


resp_ini = 0.001:0.1:0.5;

for i = 1:length(resp)
    LTfun = @(x,y,z,v) LTint_RSM(x,y,z,resp(i),lmSTD,lmSTDdot,v);
    
    [ Flong(i) ] = long_term_CDF( LTfun,Uvals,sigmauvals,sigmawvals,X,Y,Z,joint_full_env );
    
end








































