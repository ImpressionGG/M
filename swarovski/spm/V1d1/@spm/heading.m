function txt = heading(o,txt)
%
% HEADING   Overloaded heading method for SPM objects
%
%              heading(o)          % plot heading (auto adds object id)
%              heading(o,txt)      % plot heading with custom text 
%
%              txt = headng(o)     % get heading text without plotting
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
   end

   if (nargout == 0)   
      if (nargin == 1 || nargin == 2)
         heading(corazon(o),txt);
      else
         error('1 or 2 input args expected');
      end
   end
end
