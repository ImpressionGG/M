function s = structure(obj)
%
% STRUCTURE   Return the data structure of a CORE or derived CORE object
%
%    This is an auxillary method for straight forward creation of derived
%    class objects. Given a CORE object or derived CORE object the data
%    structure will be extracted, and in case a structure member .class
%    exists it will be deleted.
%
%       obj = core(fmt,par,dat)     % create a CORE object
%       s = structure(obj)          % extract structure without .class
%
%    Example: in a constructor for a derived CORE object use the following 
%    sequence:
%
%       parent = core(typ,par,dat);
%       obj = class(structure(parent),lower(mfilename),parent);     
%
%    See also: CORE
%
   s = struct(obj);
   try
      s = rmfield(s,'class');
   catch
   end
   return
end

