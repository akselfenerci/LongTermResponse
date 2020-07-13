%% <CODES.html CODES> / <fit_main.html fit> / meta
% _A general meta-modeling class which contains a wide array of options
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%
%% Syntax
% * |meta=CODES.sampling.meta(x,y)| builds a meta-model based on training set
% |(x,y)|.
% * |meta=CODES.sampling.meta(...,param,value)| uses a list of parameters
% |param| and values |value| (_c.f._, <#params parameter table>)
%
% <html><a id="scaling"></a></html>
%% Scaling
%
% Scaling input data is always good practice. For example, a 
% training set with |n| samples of dimension |m| is defined as:
%
% $$\mathbf{X}=\left[\begin{array}{ccc}x_1^{(1)}&\ldots&x_m^{(1)}\\\vdots&\ddots&\vdots\\x_1^{(n)}&\ldots&x_m^{(n)}\end{array}\right]$$
%
% Two main scaling are proposed:
%
% <html><h3>"Square" scaling</h3></html>
%
% $$x_i=\frac{x_i-\mathop{\min}\limits_{j}x_i^{(j)}}{\mathop{\max}\limits_{j}x_i^{(j)}-\mathop{\min}\limits_{j}x_i^{(j)}}$$
%
% <html><h3>"Circle" scaling</h3></html>
%
% $$x_i=\frac{x_i-\overline{x_i}}{S_i}$$
%
% where $\overline{x_i}$ and $S_i$ are respectively sample mean and standard
% deviation such that:
%
% $$\overline{x_i}=\frac{1}{n}\sum_{j=1}^nx_i^{(j)}$$
%
% $$S_i=\sqrt{\frac{1}{n-1}\sum_{j=1}^n\left(x_i^{(j)}-\overline{x_i}\right)^2}$$
%
% <html><a id="parameters"></a></html>
%% Parameters
% <html><table id="params" style="border: none">
%   <tr>
%     <th><span class="ms">param</span></th>
%     <th><span class="ms">value</span></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'scale'</span></td>
%     <td>{<span class="string">'square'</span>}, <span class="string">'circle'</span>, <span class="string">'none'</span></td>
%     <td>Define scaling method for the inputs (<i>c.f.</i>, <a href=#scaling>Scaling</a> for details)</td>
%   </tr>
%   <tr>
%     <td><span class="string">'UseParallel'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Switch to use parallel settings</td>
%   </tr>
% </table></html>
%
% <html><a id="properties"></a></html>
%% Properties
% * |X|: Unscaled training samples
% * |Y|: Training values
% * |labels|: Training labels (used for classification only)
% * |X_sc|: Scaled training samples
% * |dim|: Training samples dimension
% * |n|: number of training samples
% * |scalers|: Scaling factor to account for in gradient calculations
%
%% Methods
% Methods available for the class |meta| are described <meta_method.html
% here>
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
