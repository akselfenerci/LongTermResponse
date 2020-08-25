function [ int ] = LT_int( U,sigmau,sigmaw,resp )

[ Fx_d ] = short_term( U,sigmau,sigmaw,resp );

mu_dash(1) = 0.122+0.039*U;
mu_dash(2) = -0.657+0.03*U;
sigma_dash(1) = 0.3159;
sigma_dash(2) = 0.3021;
rhoY = 0.8148;
y = [sigmau sigmaw];

[ fturb_joint ] = joint_pdf_turbulence( y, mu_dash, sigma_dash, rhoY );

joint_full_env = fturb_joint.*lognpdf(U,1.0967,0.4894);

int = Fx_d*joint_full_env;

end

