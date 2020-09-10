function prop = property(obj,propname)
% 
% PROPERTY Get a property of a SHELL object
%      
%             obj = shell(format)            % create SHELL object
%             p = property(obj,'title')      % get proerty value 'title'
%
%          Supported SHELL properties:
%
%             bulk       retrieve bulk data
%             comment    object's comment
%             format     object's format
%             generic    1/0 whether generic obj (no data) or not
%             title      object's title
%
%          See also SHELL
%
   switch propname
      case 'bulk'
         prop = eval('obj.data.bulk','[]');
      case 'comment'
         prop = get(obj,'comment');
      case 'format'
         prop = obj.format;
      case 'generic'
         prop = ~isa(obj.data,'struct');
      case 'title'
         prop = get(obj,'title');
      case 'smart'
         try
            prop = 1;  dat = data(bulk(obj));
         catch
            prop = 0;
         end
      otherwise
         prop = [];
   end
   return
   
%eof
