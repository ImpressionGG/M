function o = text(o,msg,pos,size,hori,vert)
%
% TEXT   Place a text string to relative axis coordinates (0..1/0..1)
%
%        Relative coordinates:
%
%           o = text(o,msg1,[x,y,z],size,hori,vert)
%           o = text(o,msg2)           % re-use options, but next line!
%
%        Absolute coordinates:
%
%           o = text(o,msg1,{x,y,z},size,hori,vert)
%           o = text(o,msg2)           % re-use options, but next line!
%
%        Arguments x,y,size,x,y are stored in options and are re-used
%        in the next call of text(o,...) or can be set alternatively as
%        options.
%
%           o = opt(o,'x',x)
%           o = opt(o,'y',y)
%           o = opt(o,'z',z)
%           o = opt(o,'size',10)
%           o = opt(o,'hori','left')   % left/center/right
%           o = opt(o,'vert','top')    % baseline/top/cap/middle/bottom
%
%           o = text(o,msg1,[x,y])
%           o = text(o,msg2)           % place to next line
%
%           hdl = work(o,'hdl');
%
%        Examples:
%
%           o = text(o,'',[0.5,1.0],10,'center','mid')
%           o = text(o,'Text 1');
%           o = text(o,'Text 2');
%           
%           o = text(o,'',{mean(get(gca,'xlim')),y},10,'center','bottom')
%           o = text(o,label)
%
%        See also: SURGE
%
   if (nargin < 3)
      x = opt(o,{'x',0.5});   
      y = opt(o,{'y',0.5});   
      z = opt(o,{'z',0.0});   
      pos = [x,y,z];
   end
   if (nargin < 4)
      size = opt(o,{'size',10});   
   end
   if (nargin < 5)
      hori = opt(o,{'hori','center'});   
   end
   if (nargin < 6)
      vert = opt(o,{'vert','mid'});   
   end
   
   xlim = get(gca,'xlim');
   ylim = get(gca,'ylim');
   zlim = get(gca,'zlim');
   
      % convert absolute to relative coordinates

   if iscell(pos)
      if (length(pos) < 3)
         pos{3} = 0;
      end
      
      x = (pos{1}-xlim(1)) / diff(xlim);
      y = (pos{2}-ylim(1)) / diff(ylim);
      z = (pos{3}-zlim(1)) / diff(zlim);
      
      pos = [x,y,z];
   end
   
      % convert relative to absolute coordinates
      
   if (length(pos) < 3)
      pos(3) = 0;
   end

   x = xlim(1) + pos(1) * diff(xlim);
   y = ylim(1) + pos(2) * diff(ylim);
   z = zlim(1) + pos(3) * diff(zlim);
   
      % place text and set attributes
      
   hdl = text(x,y,z,msg);
   set(hdl,'FontSize',size);
   set(hdl,'HorizontalAlignment',hori);
   set(hdl,'VerticalAlignment',vert);
   
      % store back to options
   
   if isempty(msg)
      delta = 0;
   else
      position = get(gca,'Position');
      K = 3*position(4)/0.8;           % scaling factor for subplots
      delta = 1/(K*size);
   end
   
   o = opt(o,'x',pos(1));
   o = opt(o,'y',pos(2)-delta);
   o = opt(o,'z',pos(3));
   o = opt(o,'size',size);
   o = opt(o,'hori',hori);
   o = opt(o,'vert',vert);
   
   o = work(o,'hdl',hdl);
end
