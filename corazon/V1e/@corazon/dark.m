function mode = dark(o,mode)
%
% DARK   Dark mode
%
%           dark(o,0)                  % set dark mode off
%           dark(o,1)                  % set dark mode on
%
%           dark(o)                    % set dark mode for whole figure
%           mode = dark(o)             % get dark mode (boolean)
%
%        Deal with axes only:
%
%           dark(o,'Axes');
%
%        See also: TRADE
%
   if (nargin == 2 && (isa(mode,'double') || isa(mode,'logical')))
      if (mode)
         col = 0.15*[1 1 1];           % dark canvas color
      else
         col = 0.9*[1 1 1];            % bright canvas color
      end
      
      control(o,'color',col);          % set background color
      return
   elseif (nargin == 2 && isequal(mode,'Axes'))
      DarkAxes(o,gca);
      return
   end
   
      % handle rest
      
   mode = opt(o,{'control.dark',0});
   if (nargout > 0)
      return
   end

%   col = o.iif(mode,0.4,0.9)*[1 1 1];  % home background color
%   setting(o,'control.color',col);
   
   if dark(o)
      fig = figure(o);                 % figure handle
      %DarkFigure(o,fig);
      
      kids = get(fig,'Children');
      for (i=1:length(kids))
         kid = kids(i);
         type = get(kid,'Type');
         
         if isequal(type,'axes')
            DarkAxes(o,kid);
            Grid(o,kid);
         end
      end
   end
end

%==========================================================================
% Dark Figure
%==========================================================================

function o = DarkFigure(o,fig)
   set(fig,'color',0.1*[1 1 1]);   
end

%==========================================================================
% Dark Axes
%==========================================================================

function o = DarkAxes(o,hax)
   darkmode = opt(o,{'control.dark',0});
   if (darkmode)
      set(hax,'Color',0.1*[1 1 1]);
   end

   col = o.iif(darkmode,0.9,0.0) * [1 1 1];
   set(hax,'Xcolor',col);
   set(hax,'Ycolor',col);
   set(hax,'Zcolor',col);
   
   hdl = get(hax,'Title');
   set(hdl,'Color',col);

   hdl = get(hax,'Xlabel');
   set(hdl,'Color',col);
   hdl = get(hax,'Ylabel');
   set(hdl,'Color',col);
   hdl = get(hax,'Zlabel');
   set(hdl,'Color',col);
   
end
function o = Grid(o,hax)
   grid(o);
   col = o.iif(opt(o,{'control.dark',0}),1.0,0.0)*[1 1 1];
   
   set(hax,'GridColor',col);
   set(hax,'GridAlpha',0.3);
end