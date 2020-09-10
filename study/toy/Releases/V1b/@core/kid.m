function kobj = kid(obj,level)
%
% KID       Return a generic (!) kid class object from a CORE object or
%           derived CORE object. Return empty if no kid.
%
%              kobj = kid(obj)
%
%           A typical sequence is:
%
%              kobj = either(kid(obj),obj);
%              prop = property(kobj,propertyname);
%
%           See also: CORE, PARENT
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
end   
