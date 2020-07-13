function Failure=G1(X)
    % Load_Abdomen
    Load_Abdomen=1.16-0.3717*X(:,2).*X(:,4)-0.00931*X(:,2).*X(:,10)-0.484*X(:,3).*X(:,9)+0.01343*X(:,6).*X(:,10);
    Failure=1-Load_Abdomen;
end