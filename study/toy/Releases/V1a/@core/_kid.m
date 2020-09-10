function kobj = kid(obj,level)
%
% KID       Return a generic (!) kid class object from a shell object or
%           derived SHELL object. Return empty if no kid.
%
%              kobj = kid(obj)
%
%           A typical sequence is:
%
%              kobj = either(kid(obj),obj);
%              prop = property(kobj,propertyname);
%
%           See also: SHELL, PARENT
%
   kidclass = get(obj,'class');
   
   if (isempty(kidclass))
      kobj = [];
      return;
   end
   
   cmd = ['kobj = ',kidclass,';'];
   eval(cmd);
   
   if (nargin < 2)
      level = 0;
   end
   
   if (level > 0 && ~isempty(kobj))
      kobj = kid(kobj,level-1);     % recursive call
   end
   
   return
   
%eof   