function list = cyclist(obj,name,n)
%
% CYCLIST  Get cyclical list for sequential plots. As a first trial try  to
%          get base list from object's parameters. If no parameters set
%          then try to get base list from object's options.
%
%             list = cyclist(obj,optname,n)    % get cyclical list
%
%          Examples:
%
%             ylimits = cyclist(obj,'ylim',n)   
%             clist = cyclist(obj,'color',n)    % same as colorlist(obj,n)   
%
%          See also: CORE, PLOT, COLORLIST

   base = eval('get(obj,name)','[]');
   if (isempty(base))
      base = eval('option(obj,name)','[]');
   end

   list = {};              
   if (isempty(base))
      return;                  % return empty list if no setting found
   end
   
   if (~iscell(base))
      base = {base};           % always has to be a list!
   end

      % now cyclically extend base list until we have n list items
         
   for (i=1:n)
      list{i} = base{1+rem(i-1,length(base))};  % extend list
   end
   return
      
%eof   