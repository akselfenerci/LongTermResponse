function varargout=gauss(x,y,theta)
    % Gaussian kernel
    if nargout<2
        varargout{1}=exp(-pdist2(x,y).^2/(2*theta^2));
    else
        x_gen=permute(x,[1 3 2]);
        y_gen=permute(y,[3 1 2]);
        diff=bsxfun(@minus,x_gen,y_gen);
        varargout{1}=exp(-sum(diff.^2,3)/(2*theta^2));
        varargout{2}=bsxfun(@times,-permute(diff,[2 3 1])/theta^2,permute(varargout{1},[2 3 1]));
    end
end

