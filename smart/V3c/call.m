function call(fig)
%
% READY   Indicate a ready state by changing mouse pointer to an arrow symbol.
%
%            ready        % change mouse pointer for current figure
%            ready(2)     % change mouse pointer for figure 2
%
   if (nargin < 1)
      fig = gcf;
   end
   set(fig,'pointer','arrow');
   
% eof   
