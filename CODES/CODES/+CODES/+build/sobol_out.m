classdef sobol_out
    properties
        S1;
        S2;
        St;
        S1_CI_boot;
        S2_CI_boot;
        St_CI_boot;
        bar_plot;
        err_plot;
        conv_plot;
    end
    properties(Hidden=true)
        is_CI_boot=false;
        is_bar_plot=false;
        is_err_plot=false;
        is_conv_plot=false;
        fct_CI_boot;
        nx;
        ny;
    end
    methods
        function obj=sobol_out(S,CI_boot,pie_plot,err_plot,auth,conv_plot,compute_CI_boot)
            [~,obj.nx,obj.ny]=size(S{1});
            ylab=cell(1,obj.ny);
            for i=1:obj.ny
                ylab{i}=['Y_' num2str(i)];
            end
            xlab=cell(1,obj.nx);
            xxlab=cell(1,2*obj.nx);
            for i=1:obj.nx
                xlab{i}=['X_' num2str(i)];
                xxlab{i}=['min X_' num2str(i)];
                xxlab{obj.nx+i}=['max X_' num2str(i)];
            end
            obj.S1=CODES.build.array(S{1},{'Est 1','Est 2'},xlab,ylab);
            obj.S2=CODES.build.array(S{2},xlab,xlab,ylab);
            obj.St=CODES.build.array(S{3},{'Est 1','Est 2'},xlab,ylab);
            if nargin>1 && ~isempty(CI_boot{1})
                obj.is_CI_boot=true;
                obj.S1_CI_boot=CODES.build.array(CI_boot{1},{'min est 1','max est 1','min est 2','max est 2'},xlab,ylab);
                obj.S2_CI_boot=CODES.build.array(CI_boot{2},xxlab,xlab,ylab);
                obj.St_CI_boot=CODES.build.array(CI_boot{3},{'min est 1','max est 1','min est 2','max est 2'},xlab,ylab);
            end
            if nargin>2
                obj.is_bar_plot=true;
                obj.bar_plot=pie_plot;
            end
            if nargin>3 && auth
                obj.is_err_plot=true;
                obj.err_plot=err_plot;
            end
            if nargin>5
                obj.is_conv_plot=true;
                obj.conv_plot=conv_plot;
            end
            if nargin>6
                obj.fct_CI_boot=compute_CI_boot;
            end
        end
        function obj=compute_CI_boot(obj,varargin)
            ylab=cell(1,obj.ny);
            for i=1:obj.ny
                ylab{i}=['Y_' num2str(i)];
            end
            xlab=cell(1,obj.nx);
            xxlab=cell(1,2*obj.nx);
            for i=1:obj.nx
                xlab{i}=['X_' num2str(i)];
                xxlab{i}=['min X_' num2str(i)];
                xxlab{obj.nx+i}=['max X_' num2str(i)];
            end
            [S1_CI,S2_CI,St_CI]=obj.fct_CI_boot(varargin);
            obj.is_CI_boot=true;
            obj.S1_CI_boot=CODES.build.array(S1_CI,{'min est 1','max est 1','min est 2','max est 2'},xlab,ylab);
            obj.S2_CI_boot=CODES.build.array(S2_CI,xxlab,xlab,ylab);
            obj.St_CI_boot=CODES.build.array(St_CI,{'min est 1','max est 1','min est 2','max est 2'},xlab,ylab);
        end
        function disp(obj)
            offset=25;
            disp([sprintf('%*s',offset,'S1:') ' [2x' num2str(obj.nx) 'x' num2str(obj.ny) ' double]'])
            disp([sprintf('%*s',offset,'S2:') ' [2x' num2str(obj.nx) 'x' num2str(obj.ny) ' double]'])
            disp([sprintf('%*s',offset,'St:') ' [2x' num2str(obj.nx) 'x' num2str(obj.ny) ' double]'])
            if obj.is_CI_boot
                disp([sprintf('%*s',offset,'S1_CI_boot:') ' [4x' num2str(obj.nx) 'x' num2str(obj.ny) ' double]'])
                disp([sprintf('%*s',offset,'S2_CI_boot:') ' [4x' num2str(obj.nx) 'x' num2str(obj.ny) ' double]'])
                disp([sprintf('%*s',offset,'St_CI_boot:') ' [4x' num2str(obj.nx) 'x' num2str(obj.ny) ' double]'])
            end
            if obj.is_bar_plot
                disp([sprintf('%*s',offset,'bar_plot():') ' bar plot of the Sobol'' indices'])
            end
            if obj.is_err_plot
                disp([sprintf('%*s',offset,'err_plot():') ' error plot of the Sobol'' indices (require CI_boot)'])
            end
            if obj.is_conv_plot
                disp([sprintf('%*s',offset,'conv_plot(seq):') ' compute convergence plot for each'])
                disp([sprintf('%*s',offset,' ') ' sample size in seq (max(seq) must be lower than n)'])
            end
            disp([sprintf('%*s',offset,'compute_CI_boot(...):') ' compute confidence interval. Accepts two options:'])
            disp([sprintf('%*s',offset,' ') ' ''alpha'' (default 0.05) and ''type'' (default ''bca'').'])
        end
    end
end

