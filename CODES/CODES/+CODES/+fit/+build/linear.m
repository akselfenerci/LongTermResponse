function varargout=linear(x,y)
    % Linear kernel
    K=x*y';
    switch nargout
        case {0,1}
            varargout{1}=K;
        case 2
            varargout{1}=K;
            varargout{2}=repmat(y,[1 1 size(x,1)]);
    end

end

