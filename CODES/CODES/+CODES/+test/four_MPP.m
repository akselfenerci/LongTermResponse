function y=four_MPP(x)
    % A complex 3D limit state with 8 MPP at equal distance from the origin
    y=x(:,1);
    A=(-x(:,2)+sign(x(:,1)).*6./x(:,1));
    B=(x(:,2)+sign(x(:,1)).*6./x(:,1));
    y(x(:,2)>0)=A(x(:,2)>0);
    y(x(:,2)<=0)=B(x(:,2)<=0);
end

