%% <CODES.html CODES> / <common.html common> / snapshot
% _Save figure_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |CODES.common.snapshot(param,value)| uses a list of
% parameters |param| and values |value| (see, <#params parameter table>)
%
%% Parameters
% <html><table id="params" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'name'</span></td>
%     <td>string, {<span class="string">'figure'</span>}</td>
%     <td>File name without extension.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'fig'</span></td>
%     <td>handle, {<tt>gcf</tt>}</td>
%     <td>Figure handle.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'ext'</span></td>
%     <td>string, {<span class="string">'pdf'</span>}</td>
%     <td>Extension type. Only optimized for <span class="string">'pdf'</span> and <span class="string">'png'</span>, although other extensions should produce good results.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'res'</span></td>
%     <td>numeric, {<tt>300</tt>}</td>
%     <td>Resolution for non vectorial format.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'crop'</span></td>
%     <td>logical, {<tt>true</tt>}</td>
%     <td>Wether the plot should be croped. Rely on <tt>pdfcrop</tt> and <tt>imagemagick</tt> to be installed.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'matlab'</span></td>
%     <td>logical, {<tt>true</tt>}</td>
%     <td>Save a matlab figure (.fig) in addition.</td>
%   </tr>
% </table></html>
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
