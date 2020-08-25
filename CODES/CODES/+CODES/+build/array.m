classdef array
    properties(Hidden=true)
        M;
        xlab=[];
        ylab=[];
        zlab=[];
    end
    methods
        function obj=array(M,x,y,z)
            obj.M=M;
            if nargin>1
                obj.xlab=x;
            end
            if nargin>2
                obj.ylab=y;
            end
            if nargin>3
                obj.zlab=z;
            end
        end
        function disp(obj)
            if size(obj.M,3)==1
                CODES.common.disp_matrix(obj.M,obj.xlab,obj.ylab);
            else
                for i=1:size(obj.M,3)
                    if isempty(obj.zlab)
                        disp(['Face ' num2str(i) ':'])
                    else
                        disp([obj.zlab{i} ':'])
                    end
                    CODES.common.disp_matrix(obj.M(:,:,i),obj.xlab,obj.ylab,10)
                end
            end
        end
    end
    
end

