function out = ready(fig)
%
% READY   Indicate a ready state
%
%    Indicate a ready state by changing mouse pointer to an arrow symbol.
%
%       ready        % change mouse pointer for current figure
%       ready(2)     % change mouse pointer for figure 2
%
%    See also: CORE BUSY
%
   if (nargin < 1)
      fig = gcf;
   end
   
      % 1) change pointer symbol to 'busy' symbol

   try
      set(fig,'pointer','arrow');
   catch
%     figures = get(0,'children');
%     for (i=1:length(figures))
%        set(figures(i),'pointer','arrow');
%     end
      return
   end
   
      % 2) clear busy message

   hdl = gao('busy');
   if ~isempty(hdl)
      set(hdl,'string','');
   end
   
   
   
   drawnow;
   if (nargout > 0) out = fig; end
   
   return
end   

