function hdl = heading(o,msg)
%
% HEADING  Draw figure heading
%
%             hdl = heading(o,text)       % draw figure heading
%             hdl = heading(o)            % use title as figure heading
%
%          Copyright(c): Bluenetics 2020 
%
%          See also: CORAZON, PLOT
%
   if (nargin < 2)
      msg = get(o,{'title',[class(o),' object']});
   end
   
      % have to delete existing heading
      
   kids = get(gcf,'Children');
   for (i=1:length(kids))
      kid = kids(i);
      type = get(kid,'Type');
      if (isequal(type,'axes') && isequal(get(kid,'UserData'),'*heading*'))
         delete(kid);
      end
      
   end

   hax = axes(gcf,'OuterPosition',[0 0.95 0.95 0.05]);
   
   
   hdl = text(hax,0.5,0.5,msg);
   set(hdl,'FontSize',12,'Horizontal','center','Vertical','mid');
   
   set(hax,'xtick',[],'ytick',[]);
   set(hax,'Box','off','Color','none','Xcolor','none','Ycolor','none');
   set(hax,'userdata','*heading*');      
end