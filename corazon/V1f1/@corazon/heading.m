function hdl = heading(o,msg)
%
% HEADING  Draw figure heading
%
%             hdl = heading(o,text)    % draw figure heading
%             hdl = heading(o)         % use title as figure heading
%
%          Copyright(c): Bluenetics 2020 
%
%          See also: CORAZON, PLOT
%
   if (nargin < 2)
      msg = get(o,{'title',[class(o),' object']});
   end
   if isempty(msg)
      return                           % nothing left to do - bye
   end
   
      % substitute underscores from message
     
   uscore = util(o,'uscore');
   msg = uscore(msg);
   
      % have to delete existing heading
      
   kids = get(gcf,'Children');
   for (i=1:length(kids))
      kid = kids(i);
      type = get(kid,'Type');
      if (isequal(type,'axes')) 
         kind = shelf(o,kid,'kind');   % which kind of axes?
         if isequal(kind,'heading')
            delete(kid);
         end
      end
   end

   oldhax = gca;                       % save current axes
   hax = axes(gcf,'OuterPosition',[0 0.95 0.95 0.05]);
   
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
   
   axis off
   shelf(o,hax,'kind','heading');      % provide axis kind
   shelf(o,hax,'closeup',false);       % prevents closeup control
   
   axes(oldhax);                       % restore old axes
   dark(o,'Axes');
end