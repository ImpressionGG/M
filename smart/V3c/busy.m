function out = busy(fig)
%
% BUSY    Indicate a busy state by changing mouse pointer to a watch symbol.
%
%            busy          % change mouse pointer for current figure
%            busy(2)       % change mouse pointer for figure 2
%
%         See also: SMART READY
%
   if (nargin < 1)
      fig = gcf;
   end
   set(fig,'pointer','watch');
   
   drawnow;
   if (nargout > 0),
      out = fig;
   end
   
   return
   
% eof   
