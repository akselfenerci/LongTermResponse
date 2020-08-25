function nv=struct2nv(struc)
    % Convert structure to name-value pairs (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/struct2nv.html');web(file);">HTML</a>)
    %
    % Syntax
    %   nv=CODES.common.struct2nv(struct)
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    names=fieldnames(struc);
    nb_names=length(names);
    nv=cell(nb_names,2);
    for i=1:nb_names
        nv(i,1:2)={names{i} struc.(names{i})};
    end
    nv=reshape(nv',1,2*nb_names);
end
