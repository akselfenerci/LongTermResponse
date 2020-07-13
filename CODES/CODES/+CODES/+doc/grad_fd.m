%% <CODES.html CODES> / <common.html common> / grad_fd
% _Gradient of f at x using finite difference_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |grad=CODES.common.grad_fd(f,x)| compute the finite differences of |f|
% at |x|.
% * |[grad,fx]=CODES.common.grad_fd(...)| returns the function values
% |f(x)|.
% * |[...]=CODES.common.grad_fd(...,param,value)| uses a list of parameters
% |param| and values |value| (_c.f._, <#params parameter table>).
%
%% Usage
% If |f| returns only one output, grad is a |size(x)| matrix. If |f|
% returns multiple outputs, |f| must return a |nY| row vector and |grad| is
% the Jacobian |(nY x size(x,2) x size(x,1))| three dimensional matrix.
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
%     <td><span class="string">'type'</span></td>
%     <td><span class="string">'forward'</span>, <span class="string">'backward'</span> or {<span class="string">'central'</span>}</td>
%     <td>Type of finite difference.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'fx'</span></td>
%     <td>numeric, { [ ] }</td>
%     <td>Function value at x <tt>f(x)</tt> (save one function evaluation).</td>
%   </tr>
%   <tr>
%     <td><span class="string">'vectorial'</span></td>
%     <td>logical {<tt>false</tt>}</td>
%     <td>Wether <tt>f</tt> is vectorial or not.</td>
%   </tr>
% </table></html>
%
%% Example
% Compute finite diffence for:
%
% $$f(x)=3x^2\quad,\quad \left.\frac{\mathrm df}{\mathrm dx}\right|_{x=2}=12$$

f=@(x)3*x.^2;
grad_c=CODES.common.grad_fd(f,2,'rel_diff',1e-3);
grad_f=CODES.common.grad_fd(f,2,'type','forward','rel_diff',1e-3);
grad_b=CODES.common.grad_fd(f,2,'type','backward','rel_diff',1e-3);

CODES.common.disp_matrix([grad_c grad_f grad_b],[],...
    {'Central','Forward','Backward'})

%% See also
% <hess_fd.html hess_fd>
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
