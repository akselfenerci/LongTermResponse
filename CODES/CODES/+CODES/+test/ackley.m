function y=ackley(x)
    a=20;b=0.2;c=0.8*pi;d=-10;f=0.8;n=2;
    y=-1/f*(-a*exp(-b*sqrt(1/n)*pdist2(x,[0 0]))...
      -exp(1/n*sum(cos(c*x),2))+a+exp(1)+d);
end

