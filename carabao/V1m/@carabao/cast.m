function oo = cast(o,classname)
%
% CAST   Cast object to another class. Casting means that all properties
%        are left unchanged (also 'tag' property!).
%
%           o = carabao;               % create a CARABAO object
%           oo = cast(o,'carashit');   % cast to a CARASHIT object
%           o = cast(oo);              % cast CARASHIT back to CARABAO
%
%        After casting the CARABAO object to a CARASHIT object the 'tag'
%        property has still the value 'carabao'. This is in contrast to
%        object construction.
%
%           o = carabao;               % create a CARABAO object
%           oo = carashit(o);          % construct CARASHIT from CARABAO
%
%        Object construction sets the 'tag' property equal to the class
%        name.
%
%        There is sometimes the need to convert an object o to another
%        one with class and tag from object oo. This can be done by:
%
%           o = carabao;               % create a CARABAO object
%           oo = carashit;             % create a CARASHIT object
%           o = cast(o,oo)             % class & tag conversion to CARASHIT
%           o = cast(o,carashit)       % same as above
%
%        See also: CARABAO, CONSTRUCT
%
   if (nargin == 1)                    % cast object back to original
      if isequal(o.tag,class(o))       % any job to be done ?
         oo = o;                       % pass through
      elseif ~isa(o,'handle')          % all classes except handle class
         oo = eval(o.tag);             % construct object
         oo.type = o.type;             % copy parameters
         oo.par = o.par;               % copy parameters
         oo.data = o.data;             % copy data
         oo.work = o.work;             % copy work variables
      else                             % too dangerous to continue
         error('not allowed to balance a handle class object!');
      end
   elseif (nargin == 2) && ischar(classname)
      tag = o.tag;                     % save tag
      gamma = eval(['@',classname]);   % constructor function handle
      oo = gamma(o);                   % construct object
      oo.tag = tag;                    % restore tag
   elseif (nargin == 2) && isobject(classname)
      oo = classname;                  % classname is a reference object
      o.tag = oo.tag;                  % convert tag
      oo = cast(o);                    % balne object => convert also class
   else
      error('1 or 2 input args expected!');
   end
end
