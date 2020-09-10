function dark(fig)
%
% DARK   Set dark background of figure
%
%        See also: BRIGHT, WHITEBG
%
   if (nargin < 1),
      fig = gcf;
   end
   
   figure(fig); % figure(gcf);  % shg
%    gca;          % be sure to have axes
%    
%    haxes = get(fig,'children');
   haxes =  get(fig,'CurrentAxes');
   if isempty(haxes),
      haxes = axes('Parent',fig);
   end
   
   if ~isempty(haxes),
      col = get(haxes(1),'color');
   
      if any(col > 0)
         whitebg(fig);        % invert background and set black
      end
   end
   
   set(fig,'color',[0 0 0]); % set(gcf,'color',[0 0 0]);
   figure(fig); % figure(gcf);   % shg
   
% eof
