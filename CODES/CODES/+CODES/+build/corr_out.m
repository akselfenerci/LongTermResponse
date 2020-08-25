classdef corr_out
    properties
        rho;
        tau;
        CI;
        CI_boot;
        pie_plot;
        err_plot;
    end
    properties(Hidden=true)
        is_rho=false;
        is_tau=false;
        is_CI=false;
        is_CI_boot=false;
        is_pie_plot=false;
        is_err_plot=false;
        nx;
        ny;
    end
    methods
        function obj=corr_out(kind,rho,CI,CI_boot,pie_plot,err_plot,auth)
            [obj.ny,obj.nx]=size(rho);
            ylab=cell(1,obj.ny);
            for i=1:obj.ny
                ylab{i}=['Y_' num2str(i)];
            end
            xlab=cell(1,obj.nx);
            for i=1:obj.nx
                xlab{i}=['X_' num2str(i)];
            end
            if kind==1                      % This is rho
                obj.is_rho=true;
                obj.rho=CODES.build.array(rho,ylab,xlab);
            elseif kind==2                  % This is tau
                obj.is_tau=true;
                obj.tau=CODES.build.array(rho,ylab,xlab);
            end
            if nargin>2 && ~isempty(CI)
                obj.is_CI=true;
                obj.CI=CODES.build.array(CI,{'min','max'},xlab,ylab);
            end
            if nargin>3 && ~isempty(CI_boot)
                obj.is_CI_boot=true;
                obj.CI_boot=CODES.build.array(CI_boot,{'min','max'},xlab,ylab);
            end
            if nargin>4
                obj.is_pie_plot=true;
                obj.pie_plot=pie_plot;
            end
            if nargin>5 && auth
                obj.is_err_plot=true;
                obj.err_plot=err_plot;
            end
        end
        function disp(obj)
            if obj.is_rho
                disp([sprintf('%16s','rho:') ' [' num2str(obj.ny) 'x' num2str(obj.nx) ' double]'])
            end
            if obj.is_tau
                disp([sprintf('%16s','tau:') ' [' num2str(obj.ny) 'x' num2str(obj.nx) ' double]'])
            end
            if obj.is_CI
                disp([sprintf('%16s','CI:') ' [2x' num2str(obj.nx) 'x' num2str(obj.ny) ' double]'])
            end
            if obj.is_CI_boot
                disp([sprintf('%16s','CI_boot:') ' [2x' num2str(obj.nx) 'x' num2str(obj.ny) ' double]'])
            end
            if obj.is_pie_plot
                disp([sprintf('%16s','pie_plot():') ' pie plot of the coefficients'])
            end
            if obj.is_err_plot
                disp([sprintf('%16s','err_plot():') ' error plot of the coefficients (require either CI or CI_boot)'])
            end
        end
    end
end

