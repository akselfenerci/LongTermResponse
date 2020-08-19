function [ u ] = transform_x_to_u( xx )

sz = size(xx,2);
xx1 = xx(:,1);
xx2 = xx(:,2);
xx3 = xx(:,3);

% uu1 = norminv(wblcdf(xx1,5.1941,1.7946));
uu1 = norminv(logncdf(xx(1),1.0967,0.4894));

% orthogonal transform
[~,covYcell] = cellfun(@covX_given_xx1, num2cell(xx1),'UniformOutput',0);

[A,d] = cellfun(@eig,covYcell,'UniformOutput',0);
TT = cellfun(@(x,y) sqrt(x)'\y', d, A,'UniformOutput',0);

mu_dash2 = @(u) 0.122+0.039*u;
mu_dash3 = @(u) -0.657+0.03*u;
mu_dash2 = cellfun(@(x) mu_dash2(x), num2cell(xx1),'UniformOutput',0);    
mu_dash3 = cellfun(@(x) mu_dash3(x), num2cell(xx1),'UniformOutput',0);    

u2u3 = cellfun(@(x2,x3,mu2,mu3,t) t*(log(vertcat(x2,x3))-vertcat(mu2,mu3)),num2cell(xx2),num2cell(xx3), mu_dash2,mu_dash3, TT,'UniformOutput',0);

uu2 = cell2mat(cellfun(@(x) x(1), u2u3,'UniformOutput',0));
uu3 = cell2mat(cellfun(@(x) x(2), u2u3,'UniformOutput',0));

u = horzcat(uu1,uu2,uu3);


if sz > 3
    [ std,stddot ] = short_term_response( xx(:,1),xx(:,2),xx(:,3) );
    
    Fx = zeros(size(xx,1),1);
    Tshort = 600;
    for i = 1:size(xx,1)
        [ Fx(i) ] = short_term_extreme( std,stddot,Tshort,xx(i,4) );
    end
    uu4 = norminv(Fx);
    
    u = horzcat(u,uu4);
end


end

