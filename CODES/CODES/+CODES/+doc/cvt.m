%% <CODES.html CODES> / <method.html sampling> / cvt
% _Generate centroidal Voronoi tessellation samples_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |x=CODES.sampling.cvt(N,dim)| returns an N-by-dim matrix, |x|, containing centroidal Voronoi tessellation samples of |N| values in |dim| dimensions. 
% * |x=CODES.sampling.cvt(...,'param',value)| uses a list of parameters
% |param|
% and values |value| (see <#params parameter table>).
%
%% Parameters
% <html><table id="params" style="border: none">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'dummies'</span></td>
%     <td>positive integer, {1e6}</td>
%     <td>Number of dummy points for centroid calculation</td>
%   </tr>
%   <tr>
%     <td><span class="string">'max_iter'</span></td>
%     <td>positive integer, {50}</td>
%     <td>Maximum number of iterations</td>
%   </tr>
%   <tr>
%     <td><span class="string">'delta'</span></td>
%     <td>positive real, {1e-4}</td>
%     <td>Stopping tolerance</td>
%   </tr>
%   <tr>
%     <td><span class="string">'lb'</span></td>
%     <td>(1 x <i>dim</i>) real, {<b>0</b>}</td>
%     <td>Minimum value of cvt samples per dimension</td>
%   </tr>
%   <tr>
%     <td><span class="string">'ub'</span></td>
%     <td>(1 x <i>dim</i>) real, {<b>1</b>}</td>
%     <td>Maximum value of cvt samples per dimension</td>
%   </tr>
%   <tr>
%     <td><span class="string">'halton'</span></td>
%     <td>logical, {<tt>true</tt>}</td>
%     <td>Use Halton sequence instead of random samples</td>
%   </tr>
%   <tr>
%     <td><span class="string">'kmeans'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Use built-in Matlab <tt>kmeans</tt> function. Using <tt>kmeans</tt> leads to more accurate results but longer computation time.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'kmean_options'</span></td>
%     <td>cell, { {} }</td>
%     <td>Name-value cell options for the <tt>kmeans</tt> function. See <a href="struct2nv.html">struct2nv</a></td>
%   </tr>
%   <tr>
%     <td><span class="string">'display'</span></td>
%     <td>logical, {<tt>true</tt>}</td>
%     <td>Level of display</td>
%   </tr>
%   <tr>
%     <td><span class="string">'force_new'</i></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Force to make new CVT</td>
%   </tr>
%   <tr>
%     <td><span class="string">'force_save'</i></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Force to save CVT</td>
%   </tr>
%   <tr>
%     <td><span class="string">'region'</i></td>
%     <td>function_handle, { [ ] }</td>
%     <td>Function that defines a specific region (&ge;0)</td>
%   </tr>
% </table></html>
%
%% Example
% Compute a CVT of 9 points in 2 dimensions and plot

x=CODES.sampling.cvt(9,2);
figure('Position',[200 200 500 500])
plot(x(:,1),x(:,2),'bo')
axis([0 1 0 1])
axis square

%% Mini Tutorial
%
% <html>
% <link rel="stylesheet" type="text/css" href="demoindex.css"></link>
%     <table border="0" cellspacing="0" cellpadding="0" style="width:491px">
%         <tr class="demorow">
%             <td class="demopanel-thumbnail"><a href="Test_method_cvt.html"><img src="type_m-file.png"></a></td>
%             <td class="demopanel-description"><a href="Test_method_cvt.html">A mini tutorial of the capabilities of the <tt>cvt</tt> function.</a><br></td>
%         </tr>
%     </table>
% </html>
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
