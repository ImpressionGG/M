function hdl = footer(o,msg)
%
% FOOTER  Draw figure footer
%
%             hdl = footer(o,text)    % draw figure footer
%
%          Options:
%             restore      % restore current axes (default: false)
%
%          Remarks: footer() implicitely calls 'hold off' at the end
%
%          Copyright(c): Bluenetics 2021
%
%          See also: CORAZON, PLOT, HEADING
%
   if (nargin < 2)
      error('at least two input args expected');
   end
   if isempty(msg)
      return                           % nothing left to do - bye
   end
   
      % substitute underscores from message
     
   uscore = util(o,'uscore');
   msg = uscore(msg);
   
      % have to delete existing footer
      
   Cleanup(o);
   
   oldhax = gca;                       % save current axes
   hax = axes(gcf,'OuterPosition',[0 0.00 0.95 0.05]);
   
      % calculate font size
      
   spos = get(0,'ScreenSize');         % screen sizes
   fig = figure(o);
   if isempty(fig)
      fig = gcf;
   end
   fpos = get(fig,'Position');         % figure sizes
   ratio = fpos(4)/spos(4);
   ratio = max(ratio,0.5)-0.5;         % height ratio
   size = floor(10 + 20*ratio);        % dynamic font size
   
   hdl = text(hax,0.5,0.5,msg);
   set(hdl,'FontSize',size,'Horizontal','center','Vertical','mid');
   if dark(o)
      set(hdl,'Color',0.9*[1 1 1]);
   end
   
   axis(hax,'off');
   shelf(o,hax,'kind','footer');       % provide axis kind
   shelf(o,hax,'closeup',false);       % prevents closeup control
   
   if opt(o,{'restore',false})
      axes(oldhax);                    % restore old axes
   end
   dark(o,'Axes');
end

%==========================================================================
% Helper
%==========================================================================

function Cleanup(o)
   fig = figure(o);
   kids = get(fig,'Children');
   for (i=1:length(kids))
      kid = kids(i);
      type = get(kid,'Type');
      if (isequal(type,'axes')) 
         kind = shelf(o,kid,'kind');   % which kind of axes?
         if isequal(kind,'footer')
            delete(kid);
         end
      end
   end
end