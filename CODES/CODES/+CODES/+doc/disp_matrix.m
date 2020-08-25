%% <CODES.html CODES> / <common.html common> / disp_matrix
% _Display matrix with labels_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |CODES.common.disp_matrix(A)| displays |A|.
% * |CODES.common.disp_matrix(A,xlab)| displays |A| with x labels |xlab| on
% the left.
% * |CODES.common.disp_matrix(A,xlab,ylab)| displays |A| with x labels
% |xlab| on the left and y labels |ylab| on the top. If no x labels, set
% |xlab=[]|.
% * |CODES.common.disp_matrix(...,offset)| offset the displayed matrix by
% |offset spaces to the right.
%
%% Usage
% |xlab| must be empty (|[]|) or a cell array such that
% |length(xlab)=size(A,1)|. |ylab| must be empty (|[]|) or a cell array
% such that |length(ylab)=size(A,2)|.
%
%% Example
% Display magic matrix:

CODES.common.disp_matrix(magic(3),{'X1','X2','X3'},{'Y1','Y2','Y3'})

%% See also
% <disp_box.html disp_box> <time.html time>

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
