function heading(o,txt)
%
% HEADING   Overloaded heading method for SPM objects
%
%              heading(o)          % auto adds object id
%              heading(o,txt)
%
%           Copyright(c): Bluenetics 2020
%
%            See also: SPM
%
   if (nargin == 1)
      tit = get(o,{'title',''});
      txt = o.either(tit,'SPM Object');

      oid = id(o);
      if ~isempty(oid);
         txt = [txt,' (',oid,')'];
      end
      heading(corazon(o),txt);
   elseif (nargin == 2)
      heading(corazon(o),txt);
   else
      error('1 or 2 input args expected');
   end
      