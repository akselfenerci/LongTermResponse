function disp_box(str,frame)
    % Framed text display(<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/disp_box.html');web(file);">HTML</a>)
    %
    % Syntax
    %   CODES.common.disp_box(str) display str framed in # symbols
    %   CODES.common.disp_box(str,frame) display str framed in frame
    %   symbols
    %
    % Example
    %   CODES.common.disp_box('Hello world!')
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    %
    % See also
    % CODES.common.disp_matrix CODES.common.time
    if nargin<2
        frame='#';
    end
    l=length(str);
    disp(' ')
    disp(repmat(frame,1,l+4))
    disp([frame ' ' str ' ' frame])
    disp(repmat(frame,1,l+4))
    disp(' ')
end
