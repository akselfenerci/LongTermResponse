function Failure=G3(X)
    % Deflection Middle Rib
    Deflection_Middle=33.86+2.95*X(:,3)+0.1792*X(:,10)-5.057*X(:,1).*X(:,2)-11*X(:,2).*X(:,8)-0.0215*X(:,5).*X(:,10)-9.98*X(:,7).*X(:,8)+22*X(:,8).*X(:,9);
    Failure=32-Deflection_Middle;
end