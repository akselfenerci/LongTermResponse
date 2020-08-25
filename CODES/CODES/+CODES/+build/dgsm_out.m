classdef dgsm_out
    properties
        mu;
        std;
        mu_CI;
        std_CI;
        mu_CI_boot;
        std_CI_boot;
        pie_plot;
        err_plot;
    end
    properties(Hidden=true)
        is_CI=false;
        is_CI_boot=false;
        is_pie_plot=false;
        is_err_plot=false;
        nx;
        ny;
    end
    methods
        function obj=dgsm_out(mu,std,CI,CI_boot,pie_plot,err_plot,auth)
            [obj.ny,obj.nx]=size(mu);
            ylab=cell(1,obj.ny);
            for i=1:obj.ny
                ylab{i}=['dY_' num2str(i)];
            end
            xlab=cell(1,obj.nx);
            for i=1:obj.nx
                xlab{i}=['dX_' num2str(i)];
            end
            obj.mu=CODES.build.array(mu,ylab,xlab);
            obj.std=CODES.build.array(std,ylab,xlab);
            if nargin>2 && ~isempty(CI{1})
                obj.is_CI=true;
                obj.mu_CI=CODES.build.array(CI{1},{'min','max'},xlab,ylab);
                obj.std_CI=CODES.build.array(CI{2},{'min','max'},xlab,ylab);
            end
            if nargin>3 && ~isempty(CI_boot{1})
                obj.is_CI_boot=true;
                obj.mu_CI_boot=CODES.build.array(CI_boot{1},{'min','max'},xlab,ylab);
                obj.std_CI_boot=CODES.build.array(CI_boot{2},{'min','max'},xlab,ylab);
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
            disp([sprintf('%16s','mu:') ' [' num2str(obj.ny) 'x' num2str(obj.nx) ' double]'])
            disp([sprintf('%16s','std:') ' [' num2str(obj.ny) 'x' num2str(obj.nx) ' double]'])
            if obj.is_CI
                disp([sprintf('%16s','mu_CI:') ' [2x' num2str(obj.nx) 'x' num2str(obj.ny) ' double]'])
                disp([sprintf('%16s','std_CI:') ' [2x' num2str(obj.nx) 'x' num2str(obj.ny) ' double]'])
            end
            if obj.is_CI_boot
                disp([sprintf('%16s','mu_CI_boot:') ' [2x' num2str(obj.nx) 'x' num2str(obj.ny) ' double]'])
                disp([sprintf('%16s','std_CI_boot:') ' [2x' num2str(obj.nx) 'x' num2str(obj.ny) ' double]'])
            end
            if obj.is_pie_plot
                disp([sprintf('%16s','pie_plot():') ' pie plot of the differential coefficients'])
            end
            if obj.is_err_plot
                disp([sprintf('%16s','err_plot():') ' error plot of the differential coefficients (require either CI or CI_boot)'])
            end
        end
    end
end

