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
%    Remark: if the 'color' parameter of the object is non-empty
%    the 'color' value will be used for the backround color.
%    Otherwise the background color is retrieved from control(o,'color').
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORDOBA, SHG
%
   if (nargin == 1)
      fig = figure(o);
      if isempty(fig)
         fig = gcf(o);
      end
      mode = 'off';
   elseif (nargin == 2)
      if (ischar(arg1))
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
% Set the color according to the 'color' parameter and control options
%
   background = opt(o,{'style.background','white'});
   switch background
      case 'gray'
         color = 0.9*[1 1 1];
      case 'color'
         color = subplot(o,'color');
         if isempty(color)
            color = control(o,{'color',[1 1 1]});
         end
      otherwise                        % set white background 
         color = [1 1 1];
   end
   set(fig,'color',color);
end
