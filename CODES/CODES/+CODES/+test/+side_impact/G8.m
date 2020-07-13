function Failure=G8(X)
    % Force Pubic
    Force_Public=4.72-0.5*X(:,4)-0.19*X(:,2).*X(:,3)-0.0122*X(:,4).*X(:,10)+0.009325*X(:,6).*X(:,10)+0.000191*X(:,11).^2;
    Failure=4-Force_Public;
end