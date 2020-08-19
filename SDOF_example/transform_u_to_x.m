function [ x ] = transform_u_to_x( u )

sz = size(u,2);

uu1 = u(:,1);
uu2 = u(:,2);
uu3 = u(:,3);

% xx1 = arrayfun(@(x) wblinv(x,5.1941,1.7946),arrayfun(@normcdf,uu1));
xx1 = arrayfun(@(x) logninv(x,1.0967,0.4894),arrayfun(@normcdf,uu1));

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

x = horzcat(xx1,xx2,xx3);


if sz > 3
    [ std,stddot ] = short_term_response( xx1,xx2,xx3 );
    
    Tshort = 600;
        [ xx4 ] = short_term_extreme_inv( std,stddot,Tshort,normcdf( u(:,4) ));
    
    x = horzcat(x,xx4);
end


end

