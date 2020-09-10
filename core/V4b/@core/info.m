function txt = info(obj)
% 
% INFO  Get info text of a CORE object
%      
%             obj = core(typ)             % construct a CORE object
%             txt = info(obj)             % get CORE object's info
%
%          See also CORE, GET, SET, TYPE, DISPLAY

   title = get(obj,'title');
   date = get(obj,'date');
   time = get(obj,'time');
   typ = type(obj);
   
   if (isempty(title))
      txt = [class(obj),': ',typ];
      %txt = [obj.class,': ',typ];
   else
      txt = title;
   end
   
   if (~isempty(date) && isempty(time))
      %txt = [title,' (',date,')'];
   end

   if (isempty(date) && ~isempty(time))
      %txt = [title,' (',time,')'];
   end

   if (~isempty(date) && ~isempty(time))
      %txt = [title,' (',date,'@',time,')'];
   end
   
% eof
