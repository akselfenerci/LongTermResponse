function snapshot(varargin)
    % Saves pictures (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/snapshot.html');web(file);">HTML</a>)
    %
    % Syntax
    %   CODES.common.snapshot(param,value) uses a list of parameter and
    %   value, please refer to the <a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/snapshot.html');web(file);">HTML</a> documentation
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    if nargin==1
        in.name=varargin{1};
        in.fig=gcf;
        in.ext='pdf';
        in.crop=true;
        in.matlab=true;
    else
        input=inputParser;
        input.KeepUnmatched=false;
        input.PartialMatching=false;
        input.addOptional('fig',gcf,@ishandle);             % Figure handle
        input.addOptional('name','figure',@ischar);         % File name
        input.addOptional('ext','pdf',@ischar);             % Extensions
        input.addOptional('res',300,@isnumeric);            % Resolution
        input.addOptional('crop',true,@islogical);          % Use crop
        input.addOptional('matlab',true,@islogical);        % Save a matlab figure
        input.parse(varargin{:})
        in=input.Results;
    end
    % Save figure
    set(in.fig,'Units','inches');
    pos=get(in.fig,'Position');
    set(in.fig,'PaperUnits','inches',...
        'PaperPosition',[0 0 pos(3) pos(4)],...
        'PaperSize',[pos(3) pos(4)]);
    if in.matlab
        savefig(in.fig,[in.name '.fig']);
    end
    if strcmpi(in.ext,'pdf')
        saveas(in.fig,in.name,in.ext);
        if in.crop
            temp=strsplit(in.name,'/');
            if ~all(size(temp)==[1 1])
                cd(strjoin(temp(1:end-1),'/'));
                [flag,~]=system(['pdfcrop ' temp{end} '.pdf ' temp{end} '.pdf']);
                cd(repmat('../',1,size(temp,2)-1));
            else
                [flag,~]=system(['pdfcrop ' in.name '.pdf ' in.name '.pdf']);
            end
            if flag~=0
                warning('pdfcrop failed');
            end
        end
    else
        % Find pathes
        % wmic /output:test.csv product get name, installLocation
        % /format:csv
        print(in.fig,['-d' in.ext],['-r' num2str(in.res)],in.name);
        if in.crop
            if isunix
                [flag,~]=system(['convert ' in.name '.' in.ext ' -trim +repage ' in.name '.' in.ext]);
            else
                
                [flag,~]=system(['convert ' in.name '.' in.ext ' -trim +repage ' in.name '.' in.ext]);
                if flag~=0
                    path_im='C:\Program Files\ImageMagick-6.8.9-Q16\';
                    [flag,~]=system(['"' path_im 'convert.exe" ' in.name '.' in.ext ' -trim +repage ' in.name '.' in.ext]);
                end
            end
            if flag~=0
                warning('imagemagick failed');
            end
        end
    end
end
