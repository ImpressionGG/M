function dark(fig)
%
% DARK   Set dark background of figure
%
%             dark                % use current figure
%             dark(fig)           % use specified figure
%
%        See also: CORE, BRIGHT
%
   if (nargin < 1) fig = gcf; end
   
   if strcmp(get(fig,'visible'),'on')
      figure(fig);
   end
   gca;          % be sure to have axes
   
   haxes = get(fig,'children');
   
   if length(haxes) > 0
      for (i=1:length(haxes))
         type = get(haxes(i),'type');
         switch type
            case 'axes'
               col = get(haxes(i),'color');
   
               if any(col > 0)
                  whitebg(fig);        % invert background and set black
               end
         end
      end
   end
   
   set(gcf,'color',[0 0 0]);
   if strcmp(get(fig,'visible'),'on')
      figure(fig);                     % shg
   end
   
% eof
