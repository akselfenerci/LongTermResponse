function Failure=G7(X)
    % VC Lower
    VC_Lower=0.74-0.61*X(:,2)-0.163*X(:,3).*X(:,8)+0.001232*X(:,3).*X(:,10)-0.166*X(:,7).*X(:,9)+0.227*X(:,2).^2;
    Failure=0.32-VC_Lower;
end