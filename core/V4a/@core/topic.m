function [out,task] = topic(obj,arg,task)
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
%       [top,task] = topic(obj);        % get topic & task
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
%    See also: CORE, NAVIGATE, VIEW, TUT
%
   if (nargout == 0)
      fprintf('*** the call topic(obj) will be obsoleted!\n');
      beep; beep; beep;
      
      cls;  bright;
      text(gao,'','position',[100 0],'halign','right','size',3);

      %%%task = get(obj,'task');
      %%%top = get(obj,'topic');
      task = option(obj,'task');
      top = option(obj,'topic');
      if ~isempty(top)
         text(gao,[top]);

         text(gao,'','position','home','size',4);
         text(gao,'§§\n');
         shg;
      end      
      view(obj,'Owner','Navigate',top,task);
      return
   end
      
% if nargout > 0 and nargin == 1 we just fetch the current topic

   if (nargin == 1)
      %%%out = get(obj,'topic');
      out = option(obj,'topic');
      task = option(obj,'task');
      return
   end
   
% for nargin > 1 we only act if current topic setting is empty   
 
   if (nargin == 3)
      
      top = arg;
      %obj = set(obj,'task',task);
      %obj = set(obj,'topic',top);
      obj = option(obj,'task',task);
      obj = option(obj,'topic',top);
      out = obj;
      
   elseif ~isempty(get(obj,'task'))

      out = obj;
      return
      
   elseif ischar(arg)
      
      %%%out = set(obj,'topic',arg);
      out = option(obj,'topic',arg);
      
   elseif isa(arg,'double')             % arg is coming from gcbo
      try
         task = get(arg,'label');
         top = get(get(arg,'parent'),'label');
         
            % don't get task/topic from gcbo if we process
            % either a Clone function call or a Rebuilf function call
         
         if strcmp(task,'Clone') || strcmp(task,'Rebuild')
            task = option(obj,'view.task');
            top = option(obj,'view.topic');
         end
         
         out = topic(obj,top,task);
      catch
         out = obj;
      end
      
   else
      error('bad argument type (arg2)!');
   end
   return
end
