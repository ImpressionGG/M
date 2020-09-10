function cls(arg1,arg2)
%
% CLS   Clear screen (without destroying menus)
%
%    Default figure = gcf:
%
%       cls               % figure = gcf, axes off
%       cls('on')         % axes visible
%       cls on            % axes visible
%       cls('off')        % axes invisible
%       cls off           % axes invisible
%
%    Specified figure = fig:
%
%       cls(fig)          % specify figure
%       cls(fig,'on')     % axes visible
%       cls(fig,'off')    % axes invisible
%
%    See also: SMART CLF
%
   if (nargin == 0)
      fig = gcf;  mode = 'off';
   elseif (nargin == 1)
      if (isstr(arg1))
         fig = gcf;  mode = arg1;
      else
         fig = arg1;  mode = 'off';
      end
   elseif (nargin == 2)
         fig = arg1;  mode = arg2;
   else
      error('clrscr(): 0,1 or 2 args expected!');
   end
   
   if strcmp(get(fig,'visible'),'on')
      figure(fig);
   end
   
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
   
   switch mode
      case 'on'
         set(gca,'visible','on')
      case 'off'
         set(gca,'visible','off')
      otherwise
         error(['clrscr(): bad mode "',mode,'"!']);
   end
   return
end   
