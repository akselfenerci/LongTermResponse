function count=linecount(filename)
    % Count number of lines in a file (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/doc/html/linecount.html');web(file);">HTML</a>)
    %
    % Syntax
    %   nb_l=CODES.common.linecount(filename) returns the number of line
    %   within the file filename
    %
    % Example
    %   count=CODES.common.linecount([fileparts(which('CODES.install')) '/+common/linecount.m']);
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    fic=fopen(filename,'rt');
    assert(fic~=-1,['Could not read: ' filename]);
    count = 0;
    while ~feof(fic)
        count=count+sum(fread(fic,16384,'char')==char(10));
    end
    fclose(fic);
end
