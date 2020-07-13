function Failure=G2(X)
    % Deflection Upper rib
    Deflection_Upper=28.98+3.818*X(:,3)-4.2*X(:,1).*X(:,2)+0.0207*X(:,5).*X(:,10)+6.63*X(:,6).*X(:,9)-7.7*X(:,7).*X(:,8)+0.32*X(:,9).*X(:,10);
    Failure=32-Deflection_Upper;
end