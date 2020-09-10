function oo = balance(o)
%
% BALANCE   Balance an object
%
%              oo = balance(o)         % get balanced object
%
%           An object is unbalanced, if object's tag differs from object's
%           class name. This happens e.g. inside a method of a base class.
%           Balancing reconstructs the original object before it got
%           unbalanced.
%
%           See also: CARABAO
%
   if isequal(o.tag,class(o))
      oo = o;                          % pass through
   elseif ~isa(o,'handle')
      oo = eval(o.tag);                % construct object
      oo.type = o.type;                % copy parameters
      oo.par = o.par;                  % copy parameters
      oo.data = o.data;                % copy data
      oo.work = o.work;                % copy work variables
   else                                % too dangerous to continue
      error('not allowed to balance a handle class object!');
   end
end