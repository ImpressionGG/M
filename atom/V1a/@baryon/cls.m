function hax = cls(o,arg1)
%
% CLS   Clear screen (without destroying menus). Set background color
%       according to control option control(o,'color').
%
%    Default figure = gcf:
%
%       cls(o)              % figure = gcf, axes off
%       cls(o,'on')         % axes visible
%       cls(o,'off')        % axes invisible
%
%    Remark: if the 'canvas' parameter of the object is non-empty
%    the 'canvas' value will be used for the canvas (backround) color.
%    Otherwise the canvas color is retrieved from control(o,'color').
%
%    See also: BARYON, SHG
%
   %either = util(o,'either');          % need some utility
   glu = gluon;
   
   if (nargin == 1)
      fig = glu.either(figure(o),gcf(o)); 
      mode = 'off';
   elseif (nargin == 2)
      if (isstr(arg1))
         fig = gcf(o);  mode = arg1;
      else
         fig = arg1;  mode = 'off';
      end
   else
      error('clrscr(): 1 or 2 args expected!');
   end
   
   if strcmp(get(fig,'visible'),'on')
      figure(fig);
   end
%
% Delete all children
%
   children = get(fig,'children');
   for (i = 1:length(children))
      hdl = children(i);
      eval('tp = get(hdl,''type'');','tp='''';');
      switch tp
         case {'uimenu'}
            'no delete!';
         otherwise
            delete(hdl);  
      end
   end
%
% Delete all callback functions
%
   set(fig,'ResizeFcn','');
%
% Handle mode
%
   switch mode
      case 'on'
         set(gca,'visible','on')
      case 'off'
         set(gca,'visible','off')
      otherwise
         error(['clrscr(): bad mode "',mode,'"!']);
   end
%
% Clear axes if nargout > 0
%
   if (nargout > 0)
      hax = cla(fig);
   end
%
% Set the color according to the 'canvas' parameter and control options
%
   color = control(o,{'color',[1 1 1]});
   color = get(o,{'canvas',color});
   set(fig,'color',color);
end
