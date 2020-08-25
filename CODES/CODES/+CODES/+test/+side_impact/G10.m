function Failure=G10(X)
    % Velocity B
    Velocity_Door=16.45-0.489*X(:,3).*X(:,7)-0.843*X(:,5).*X(:,6)+0.0432*X(:,9).*X(:,10)-0.0556*X(:,9).*X(:,11)-0.000786*X(:,11).^2;
    Failure=15.7-Velocity_Door;
end