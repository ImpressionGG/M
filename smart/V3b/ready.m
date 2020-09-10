function out = ready(fig)
%
% READY   Indicate a ready state by changing mouse pointer to an arrow symbol.
%
%            ready        % change mouse pointer for current figure
%            ready(2)     % change mouse pointer for figure 2
%
%         See also: SMART BUSY
%
   if (nargin < 1)
      fig = gcf;
   end
   set(fig,'pointer','arrow');
   
   drawnow;
   if (nargout > 0),
      out = fig;
   end
   
   return
   
% eof   
