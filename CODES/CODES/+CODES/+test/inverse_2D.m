function y=inverse_2D(x)
    % A 2D function with 4 equidistant MPP
    y=x(:,1);
    A=(-x(:,2)+sign(x(:,1)).*6./x(:,1));
    B=(x(:,2)+sign(x(:,1)).*6./x(:,1));
    y(x(:,2)>0)=A(x(:,2)>0);
    y(x(:,2)<=0)=B(x(:,2)<=0);
end

