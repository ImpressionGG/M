function dark(fig)
%
% DARK   Set dark background of figure
%
%        See also: BRIGHT, WHITEBG
%
   if (nargin < 1) fig = gcf; end
   
   figure(gcf);  % shg
   gca;          % be sure to have axes
   
   haxes = get(fig,'children');
   
   if length(haxes) > 0
      col = get(haxes(1),'color');
   
      if any(col > 0)
         whitebg(fig);        % invert background and set black
      end
   end
   
   set(gcf,'color',[0 0 0]);
   figure(gcf);   % shg
   
% eof
