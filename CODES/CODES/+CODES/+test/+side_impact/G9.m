function Failure=G9(X)
    % Velocity B
    Velocity_B=10.58-0.674*X(:,1).*X(:,2)-1.95*X(:,2).*X(:,8)+0.02054*X(:,3).*X(:,10)-0.0198*X(:,4).*X(:,10)+0.028*X(:,6).*X(:,10);
    Failure=9.9-Velocity_B;
end