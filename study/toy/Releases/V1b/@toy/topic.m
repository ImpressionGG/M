function out = topic(obj,arg,task)
%
% TOPIC   Get/provide menu item dependent object topic
%
%    Syntax
%
%    1) Clear screen and draw topic in upper right corner
%
%       topic(obj);                     % clear screen and draw topic
%
%    2) Get current topic
%
%       top = topic(obj);               % get topic
%
%    3) Set topic. This is only done if the current task setting is empty
%
%       obj = topic(obj,'My Topic');    % set topic
%       obj = title(obj,gcbo);          % provide topic from menu item
%
%    4) unconditional topic & task setting
%
%       obj = topic(obj,top,task);
%
%    See also: TOY, GET, SET
%
   if (nargout == 0)
      cls;  bright;
      text(gao,'','position',[100 0],'halign','right','size',3);

      task = get(obj,'task');
      top = get(obj,'topic');
      text(gao,[top]);
      
      text(gao,'','position','home','size',4);
      text(gao,'§§\n');
      shg;
      
      view(obj,'Owner','Navigate',top,task);
      return
   end
      
% if nargout > 0 and nargin == 1 we just fetch the current topic

   if (nargin == 1)
      out = get(obj,'topic');
      return
   end
   
% for nargin > 1 we only act if current topic setting is empty   
 
   if (nargin == 3)
      
      top = arg;
      obj = set(obj,'task',task);
      obj = set(obj,'topic',top);
      out = obj;
      
   elseif ~isempty(get(obj,'task'))

      out = obj;
      return
      
   elseif ischar(arg)
      
      out = set(obj,'topic',arg);
      
   elseif isa(arg,'double')             % arg is coming from gcbo
      
      task = get(arg,'label');
      top = get(get(arg,'parent'),'label');
      out = topic(obj,top,task);
      
   else
      error('bad argument type (arg2)!');
   end
   return
end
