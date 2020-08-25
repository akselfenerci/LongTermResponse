function hist_fd(x,pdf)  
    % Histogram of probabilities plot with number of bins defined by the Freedman-Diaconis rule (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/hist_fd.html');web(file);">HTML</a>)
    %
    % Syntax
    %   CODES.common.hist(x) plot a histogram of x
    %   CODES.common.hist(x,pdf) plot a histogram of x and overlay the
    %   function pdf on top of it
    %
    % Example
    %   x=normrnd(0,1,1000,1);
    %   CODES.common.hist(x,@normpdf)
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    R=max(x)-min(x);
    IQR=iqr(x);
    h=2*IQR/size(x,1)^(1/3);
    nb_bin=min(floor(R/h),size(x,1)/2);
    [n,x_c]=hist(x,nb_bin);
    bar(x_c,(n*nb_bin)/(R*size(x,1)));
    if nargin>1
        hold on
        fplot(pdf,[min(x) max(x)],'r-')
    end
end
