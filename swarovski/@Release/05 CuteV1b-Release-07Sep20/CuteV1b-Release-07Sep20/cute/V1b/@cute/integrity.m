function [ok,dup] = integrity(o,mode)
%
% INTEGRITY  Integrity check - check whether there are duplicate
%            packages or data objects
%
%               [ok,duplicate] = integrity(o)
%               [ok,duplicate] = integrity(o,mode)
%
%               ok = integrity(o)           % check total integrity
%               ok = integrity(o,'Total')   % check total integrity
%
%               ok = integrity(o,'Package') % check package integrity
%               ok = integrity(o,'Object')  % check object integrity
%
%            Package integrity means that there are no two package info
%            objects in the shell with same package ID. Object integrity
%            means that there are no two objects in the shell with same 
%            object id. Total integrity means Package integrity AND object
%            integrity.
%
%            Options:
%
%               display:    display integrity issues (default: true)
%
%            Copyright(c): Bluenetics 2020
%
%            See also: CUTE
%
   if (nargin > 2)
      error('1 or 2 input args expected');
   end
   
   if (nargin == 1)
      [ok,dup] = Total(o);
      return
   end
   
   switch mode
      case 'Total'
         [ok,dup] = Total(o);
      case 'Package'
         [ok,dup] = Package(o);
      case 'Object'
         [ok,dup] = Object(o);
      otherwise
         error('bad mode');
   end
end

%==========================================================================
% Helpers
%==========================================================================

function [ok,dup] = Object(o)          % Object Integrity              
   is = @o.is;                         % shorthand
   o = pull(o);                        % fetch shell object
   list = o.data;

      % create a list of object IDs
      
   ids = {};
   dup = {};
   for (i=1:length(list))
      oo = list{i};
      if ~type(o,{'cut'})
         continue
      end
      
         % at this point we deal with a 'cut' (typed) object
      
      ID = id(oo);
      if is(ID,ids)
         if ~is(ID,dup)
            dup{end+1} = ID;
         end
      else
         ids{end+1} = ID;
      end
   end
   
   ok = (length(dup) == 0);
end
function [ok,dup] = Package(o)         % Object Integrity              
   is = @o.is;                         % shorthand
   o = pull(o);                        % fetch shell object
   list = o.data;
   
      % create a list of object IDs
      
   ids = {};
   dup = {};
   for (i=1:length(list))
      oo = list{i};
      if ~type(o,{'pkg'})
         continue
      end
      
         % at this point we deal with a 'cut' (typed) object
      
      ID = id(oo);
      if is(ID,ids)
         if ~is(ID,dup)
            dup{end+1} = ID;
         end
      else
         ids{end+1} = ID;
      end
   end
   
   ok = (length(dup) == 0);
end
function [ok,dup] = Total(o)           % Object Integrity              
   is = @o.is;                         % shorthand
   o = pull(o);                        % fetch shell object
   list = o.data;
   
      % create a list of object IDs
      
   ids = {};
   dup = {};
   for (i=1:length(list))
      oo = list{i};
      
         % at this point we deal with a 'cut' (typed) object
      
      ID = id(oo);
      if is(ID,ids)
         if ~is(ID,dup)
            dup{end+1} = ID;
         end
      elseif ~isempty(ID)
         ids{end+1} = ID;
      end
   end
   
   ok = (length(dup) == 0);
end

