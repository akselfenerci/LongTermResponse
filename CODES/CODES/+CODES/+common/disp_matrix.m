function disp_matrix(A,xlab,ylab,offset)
    % Framed text display(<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/disp_box.html');web(file);">HTML</a>)
    %
    % Syntax
    %   CODES.common.disp_matrix(str) display str framed in # symbols
    %   CODES.common.disp_matrix(str,frame) display str framed in frame
    %   symbols
    %
    % Example
    %   CODES.common.disp_matrix('Hello world!')
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    %
    % See also
    % CODES.common.disp_box CODES.common.time
    [nx,ny]=size(A);
    if nargin<4
        offset=0;
    end
    if nargin<3
        ylab=[];
    else
        assert(isempty(ylab)||length(ylab)==ny,'Number of Y labels should be equal to size(A,2)')
    end
    if nargin<2
        xlab=[];
    else
        assert(isempty(xlab)||length(xlab)==nx,'Number of X labels should be equal to size(A,1)')
    end
    % Compute max size per column (except xlabel)
    ly=zeros(1,ny);
    for i=0:nx
        for j=1:ny
            if i==0 && ~isempty(ylab)
                % Use size of ylable, if defined
                ly(j)=max(ly(j),length(ylab{j}));
            elseif i~=0
                % Use size of numeric value
                ly(j)=max(ly(j),length(sprintf('%g',A(i,j))));
            end
        end
    end
    ly=ly+2;
    % Compute max size for xlabel
    lx=0;
    if ~isempty(xlab)
        % Compute max size of label
        for i=1:length(xlab)
            lx=max(lx,length(xlab{i}));
        end
    end
    % Initialize a character array for everyone
    text=char(zeros(nx+~isempty(ylab),offset+lx+sum(ly)));
    for i=0:nx
        for j=0:ny
            if i==0
                if ~isempty(ylab)
                    if j==0
                        text(i+1,offset+(1:lx))=sprintf('%*s',lx,' ');
                    elseif j==size(A,2)
                        text(i+1,offset+((sum(ly(1:j-1))+lx+1):(sum(ly(1:j))+lx)))=sprintf('%*s',ly(j),ylab{j});
                    else
                        text(i+1,offset+((sum(ly(1:j-1))+lx+1):(sum(ly(1:j))+lx)))=sprintf('%*s',ly(j),ylab{j});
                    end
                end
            else
                if j==0 && ~isempty(xlab)
                    text(i+~isempty(ylab),offset+(1:lx))=sprintf('%*s',lx,xlab{i});
                elseif j==size(A,2)
                    text(i+~isempty(ylab),offset+((sum(ly(1:j-1))+lx+1):(sum(ly(1:j))+lx)))=sprintf('%*g',ly(j),A(i,j));
                elseif j~=0
                    text(i+~isempty(ylab),offset+((sum(ly(1:j-1))+lx+1):(sum(ly(1:j))+lx)))=sprintf('%*g',ly(j),A(i,j));
                end
            end
        end
    end
    disp(text)
end
