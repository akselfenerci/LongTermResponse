%% <CODES.html CODES> / <common.html common> / hess_fd
% _Hessian of f at x using finite difference_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |H=CODES.common.hess_fd(f,x)| compute the Hessian matrix |H| using
% finite difference on |f| at |x|.
% * |[H,grad]=CODES.common.hess_fd(...)| returns the central finite
% difference of the gradient |grad|.
% * |[H,grad,fx]=CODES.common.hess_fd(...)| returns the function values
% |fx| of |f| at |x|.
% * |[...]=CODES.common.hess_fd(...,param,value)| uses a list of parameters
% |param| and values |value| (_c.f._, <#params parameter table>).
%
%% Usage
% |size(x,1)| must be equal to 1. Returns the |(size(x,2) x size(x,2))|
% Hessian matrix.
%
%% Parameters
% <html><table id="params" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'rel_diff'</span></td>
%     <td>positive numeric, {1e-5}</td>
%     <td>Finite difference step size.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'fx'</span></td>
%     <td>numeric, { [ ] }</td>
%     <td>Function value at x <tt>f(x)</tt> (save one function evaluation).</td>
%   </tr>
% </table></html>
%
%% Example
% Compute finite diffence for:
%
% $$f(x)=3x_1^2+x_2^3+x_1x_2\quad,\quad \left.\frac{\mathrm d^2f}{\mathrm d\mathbf{x}^2}\right|_{\mathbf{x}=[2,3]}=\left[\begin{array}{cc}6 & 1\\1 & 18\end{array}\right]$$

f=@(x)3*x(:,1).^2+x(:,2).^3+x(:,1)*x(:,2);
H=CODES.common.hess_fd(f,[2 3]);

CODES.common.disp_matrix(H,{'d2fdX12','d2fdX1X2'},...
    {'d2fdX2X1','d2fdX22'})

%% See also
% <grad_fd.html grad_fd>
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
