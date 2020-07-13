%% <CODES.html CODES> / <common.html common> / multi_fmincon
% _Find minimum of constrained nonlinear multivariable function using multiple starting points_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |opti=CODES.common.multi_fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)|
% uses Matlab fmincon definition where |x0| is an |(n x dim)| matrix of
% |n| starting points. 
% * |opti=CODES.common.multi_fmincon(...,parallel)| evaluates using
% |parfor| if |parallel=true| (default) or using |for| if |parallel=false|.
% * |[opti,valid]=CODES.common.multi_fmincon(...)| returns the optimum
% |opti| and all the feasible local optima |valid|.
% * |[opti,valid,local]=CODES.common.multi_fmincon(...)| returns all local
% optima |local|.
% * |[opti,valid,local,fval]=CODES.common.multi_fmincon(...)| returns all
% function values |fval| at local optima.
% * |[opti,valid,local,fval,outputs]=CODES.common.multi_fmincon(...)|
%   returns the output structures of the |n| runs |outputs|.
%
%%
%%
% <html>Copyright &copy; 2015 Computational Optimal Design of Engineering Systems
% (CODES) Laboratory. University of Arizona.</html>
%%
%
% <html><table style="border: none">
%   <tr style="border: none">
%     <td style="border: none;padding-left: 0px;">
%       <a href ="http://codes.arizona.edu/"><img style="height: 50px;" src ="CODES_logo.png"></a>
%     </td><td style="border: none; vertical-align: middle;padding-left: 10px;">
%       <a href ="http://codes.arizona.edu/"><span style="font-weight:bold;font-family:Arial;font-size: 20px;color: #002147"><span style="color: #AB0520;">C</span>omputational <span style="color: #AB0520;">O</span>ptimal <span style="color: #AB0520;">D</span>esign of<br><span style="color: #AB0520;">E</span>ngineering <span style="color: #AB0520;">S</span>ystems</span></a>
%     </td><td style="border: none;padding-right: 0px;">
%       <a href = "http://www.arizona.edu/"><img style="height: 50px;" src = "AZlogo.png"></a>
%     </td>
%   </tr>
% </table></html>
