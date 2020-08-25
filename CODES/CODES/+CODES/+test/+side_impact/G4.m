function Failure=G4(X)
    % Deflection Lower Rib
    Deflection_Lower=46.36-9.9*X(:,2)-12.9*X(:,1).*X(:,8)+0.1107*X(:,3).*X(:,10);
    Failure=32-Deflection_Lower;
end