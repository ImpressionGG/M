function oo = cls(o,arg1)
%
% CLS   Clear screen (without destroying menus). Set background color
%       according to control option control(o,'color'). Also store axes
%       handle in output arg
%
%    Default figure = gcf:
%
%       oo = cls(o)              % figure = gcf, axes off
%       oo = cls(o,'on')         % axes visible
%       oo = cls(o,'off')        % axes invisible
%       oo = cls(o,'hold')       % set hold on
%
%    Remark: if the 'canvas' parameter of the object is non-empty
%    the 'canvas' value will be used for the canvas (backround) color.
%    Otherwise the canvas color is retrieved from control(o,'color').
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, SHG
%
   either = util(o,'either');          % need some utility
   
   if (nargin == 1)
%     fig = either(figure(o),gcf(o)); 
      fig = figure(o);
      if isempty(fig)
         fig = gcf(o);
      end
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
%     figure(fig);
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
   hax = axes(fig);                    % create axes

   hold(hax,'off');                    % hold off by default
   switch mode
      case 'on'
         set(hax,'visible','on');
      case 'off'
         set(hax,'visible','off');
      case 'hold'
         hold on;
      otherwise
         error(['clrscr(): bad mode "',mode,'"!']);
   end
%
% Clear axes if nargout > 0
%
   if (nargout > 0)
%     hax = cla(fig);
      cla(hax);
   end
%
% Set the color according to the 'canvas' parameter and control options
%
   color = opt(o,{'control.color',[1 1 1]});
   if ~dark(o)
      color = get(o,{'canvas',color});
   end
   set(fig,'color',color);
   idle(o);
   
      % set axes handle in output object
      
   oo = axes(o,hax);
end
