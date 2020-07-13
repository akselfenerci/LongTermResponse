function text=time(sec)
    % Display time in a user friendly format (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/time.html');web(file);">HTML</a>)
    %
    % Syntax
    %   CODES.common.time(sec) display sec in an appropriate format
    %
    % Example
    %   tic;p=0;
    %   for i=1:1e6
    %       p=p+i;
    %   end
    %   disp(CODES.common.time(toc));
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    %
    % See also
    % CODES.common.disp_box CODES.common.disp_matrix
    if sec>=1
        sec=ceil(sec);
    end
    if sec<1
        text=[num2str(sec,'%1.4e') ' s'];
    elseif sec<=59
        text=[num2str(sec) 's'];
    elseif sec<=3599
        min=floor(sec/60);
        sec=sec-60*min;
        text=[num2str(min) ' m ' num2str(sec) ' s'];
    elseif sec<=86399
        hours=floor(sec/3600);
        min=floor((sec-3600*hours)/60);
        sec=sec-60*min-3600*hours;
        text=[num2str(hours) ' h ' num2str(min) ' m ' num2str(sec) ' s'];
    elseif sec<=31535999
        day=floor(sec/86400);
        hours=floor((sec-86400*day)/3600);
        min=floor((sec-3600*hours-86400*day)/60);
        sec=sec-60*min-3600*hours-86400*day;
        text=[num2str(day) ' d ' num2str(hours) ' h ' num2str(min) ' m ' num2str(sec) ' s'];
    else
        years=floor(sec/31536000);
        day=floor((sec-31536000*years)/86400);
        hours=floor((sec-86400*day-31536000*years)/3600);
        min=floor((sec-3600*hours-86400*day-31536000*years)/60);
        sec=sec-60*min-3600*hours-86400*day-31536000*years;
        text=[num2str(years) ' y ' num2str(day) ' d ' num2str(hours) ' h ' num2str(min) ' m ' num2str(sec) ' s'];
    end
end
