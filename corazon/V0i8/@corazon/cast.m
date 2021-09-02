function [oo,ooo] = cast(o,classname)
%
% CAST   Cast object to another class. Casting means that all properties
%        are left unchanged (also 'tag' property!).
%
%           o = corazon;               % create a CORAZON object
%           oo = cast(o,'corshito');   % cast to a CORSHITO object
%           o = cast(oo);              % cast CORSHITO back to CORAZON
%
%           [o1,o2] = cast(o1,o2);     % cast to same type
%
%        After casting the CORAZON object to a CORSHITO object the 'tag'
%        property has still the value 'corazon'. This is in contrast to
%        object construction.
%
%           o = corazon;               % create a CORAZON object
%           oo = corshito(o);          % construct CORSHITO from CORAZON
%
%        Object construction sets the 'tag' property equal to the class
%        name.
%
%        There is sometimes the need to convert an object o to another
%        one with class and tag from object oo. This can be done by:
%
%           o = corazon;               % create a CORAZON object
%           oo = corshito;             % create a CORSHITO object
%           o = cast(o,oo)             % class & tag conversion to CORSHITO
%           o = cast(o,corshito)       % same as above
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZON, CONSTRUCT
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
   elseif (nargin==2) && (nargout==2)  % cast to same type
      o1 = o;  o2 = classname;         % rename args
      [oo,ooo] = Cast(o1,o2);          % cast to same type
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

%==========================================================================
% Cast to Same Type
%==========================================================================

function [o1,o2] = Cast(o1,o2)         % Cast Objects to be Compatible 
   if isa(o2,'double');
      if isequal(o1.type,'trf')
         o2 = trf(o1,o2);
         return
      else
         o2 = number(o1,o2);
      end
   end
   
   kind = max(Kind(o1),Kind(o2));
   switch kind
      case 0
         if ~isequal(o1.type,'trf')
            o1 = trf(o1);
         end
         if ~isequal(o2.type,'trf')
            o2 = trf(o2);
         end
         
      case 1
         if ~isequal(o1.type,'number')
            o1 = number(o1);
         end
         if ~isequal(o2.type,'number')
            o2 = number(o2);
         end
         
      case 2
         if ~isequal(o1.type,'poly')
            o1 = poly(o1);
         end
         if ~isequal(o2.type,'poly')
            o2 = poly(o2);
         end

      case 3
         if ~isequal(o1.type,'ratio')
            o1 = ratio(o1);
         end
         if ~isequal(o2.type,'ratio')
            o2 = ratio(o2);
         end
         
      otherwise
         error('internal');
   end

   function kind = Kind(o)
      switch o.type
         case 'trf'
            kind = 0;
         case 'number'
            kind = 1;
         case 'poly'
            kind = 2;
         case 'ratio'
            kind = 3;
         case 'matrix'
            kind = 4;
         otherwise
            kind = NaN;
      end
   end
end
