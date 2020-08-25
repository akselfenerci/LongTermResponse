function g = rackwitz(x,lambda,C)
    % A multi dimensional non linear limit state
    if nargin==1
        lambda=2;
        C=10;
    end
    g=sum(log(normcdf(x))/lambda,2)+C;
end

