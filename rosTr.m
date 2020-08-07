function [ u ] = rosTr( xx,varargin )

sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
rhoY = 0.8148;
[ fjoint_handle ] = joint_pdf_lognormal( sigma_dash, rhoY );


% u1
u1 = norminv(logncdf(xx(1),1.0967,0.4894));

% u2
syms x y
fcond = int(fjoint_handle(x,y,xx(1)),y,0,10);
Fsu = double(int(fcond,x,0, xx(2)));
u2 = norminv(Fsu);

% u3
syms z
Fsw = double(int(fjoint_handle(xx(2),z,xx(1)),0, xx(3)));
u3 = norminv(Fsw);

u = [u1 u2 u3];
    
% u4
if length(xx) > 3
    RSM = varargin{1};
    Tshort = 600;
    [std] = predict(RSM.lmSTD,xx(1:3));
    [stddot] = predict(RSM.lmSTDdot,xx(1:3));
    std(std<0) = 1e-5;
    stddot(stddot<0) = 1e-5;
    [ Fx_d ] = short_term_extreme( std,stddot,Tshort,xx(4) );
    u4 = norminv(Fx_d);

%
    u = [u u4];
end


end

