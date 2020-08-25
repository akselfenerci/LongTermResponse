%% <CODES.html CODES> / <common.html common> / mcmc
% _Component Metropolis-Hastings_
%
% <html>
%   <style type="text/css">
%     span.string{color:#A020F0;font-family:monospace;}
%     p{text-align: justify;}
%   </style>
% </html>
%
%% Syntax
% * |x=CODEScommon.mcmc(sites,N,PDFs_target)| performs component
% Metropolis-Hastings. |sites| is a |(nc x dim)| matrix used to start |nc|
% Markov-chain. Each chain as |N| samples and |x| is the |(N x dim x Nc)|
% matrix of generated samples. |PDFs_target| is the target marginal PDFs.
% For a |(n x dim)| sample, |PDFs_target(x)| should return a |(n x dim)|
% matrix of marginal PDF values.
% * |[x,y]=CODEScommon.mcmc(sites,N,PDFs_target)| returns the |(N x 1 x
% nc)| array |y| of rejection function values (requires a rejection
% function). 
% * |[x,y,dy]=CODEScommon.mcmc(sites,N,PDFs_target)| returns the |(N x dim
% x Nc)| array |dy| of rejection gradient (requires a rejection function
% and gradient option).
% * |[...]=CODEScommon.mcmc(...,param,value)| uses a list of
% parameters |param| and values |value| (see, <#params parameter table>)
%
%% Description
% Component Metropolis-Hasting as discussed in <#ref_au Au & Beck (2001)>.
% As opposed to the regular algorithm where a _joint_ target and proposal
% PDF is provided, this variant works with _marginal_ target and proposal
% PDFs. Acceptance/rejection decision is made dimension per dimension.
%
%% Parameters
% <html><table id="params" style="border: none;width=100%">
%   <tr>
%     <th><tt>param</tt></th>
%     <th><tt>value</tt></th>
%     <th>Description</th>
%   </tr>
%   <tr>
%     <td><span class="string">'prop_rand'</span></td>
%     <td><tt>function_handle</tt>, {<tt>@(x)normrnd(x,ones(size(x)))</tt>}</td>
%     <td>Proposal random sampler. For a <tt>(n x dim)</tt> sample <tt>x</tt>, returns a <tt>(n x dim)</tt> sample of proposed candidates. By default, uses normal with mean <tt>x</tt> and standard deviation 1.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'burnin'</span></td>
%     <td>positive integer, {0}</td>
%     <td>Number of samples to be &ldquo;burned&rdquo; at the begining.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'rejection'</span></td>
%     <td><tt>function_handle</tt>, {<tt>-1</tt>}</td>
%     <td>A rejection function. For a <tt>(n x dim)</tt> sample <tt>x</tt>, <tt>rejection(x)</tt> should return a <tt>(n x 1)</tt> array of rejection function value. Samples are rejected if rejection function value is positive.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'gradient'</span></td>
%     <td>logical, {<tt>false</tt>}</td>
%     <td>Wether or not gradient of the rejection function should be returned. If <span class="string">'on'</span>, <tt>rejection</tt> should return 2 outputs <tt>[y,dy]</tt> where <tt>y</tt> and <tt>dy</tt> are the <tt>(n x 1)</tt> array of rejection function values and the <tt>(n x dim)</tt> array of rejection gradient respectively.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'initial_values'</span></td>
%     <td>numeric, { [ ] }</td>
%     <td>An array of initial rejection values.</td>
%   </tr>
%   <tr>
%     <td><span class="string">'initial_gradients'</span></td>
%     <td>numeric, { [ ] }</td>
%     <td>An array of initial gradients.</td>
%   </tr>
% </table></html>
%
%% Example
% Generate samples from an exponential distribution ($\mu=1$) while
% rejecting samples such that:
%
% $$x\leq 2$$

pdf=@(x)exppdf(x,1);
rejection=@(x)2-x;
x_mcmc=CODES.common.mcmc(3,2000,pdf,'rejection',rejection);
CODES.common.hist_fd(x_mcmc,@(x)exppdf(x,1)/(1-expcdf(2,1)))
axis([0 11 0 1])

%% References
% <html><ul style="list-style-type:none">
%   <li id="ref_au"><span style="color:#005fce;">Au & Beck
%   (2001)</span>: Au, S.-K., & Beck, J. L. (2001). <i>Estimation of small
%   failure probabilities in high dimensions by subset simulation</i>.
%   Probabilistic Engineering Mechanics, 16(4), 263-277.
%   <a href="http://dx.doi.org/10.1016/S0266-8920(01)00019-4">DOI</a></li>
% </ul></html>
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