function oo = format(o,arg2)
% 
% FORMAT   Get format of a DANAOBJ or check if DANA object has a
%          specified format
%      
%             o = danaobj(data)                    % create DANA object
%             fmt = format(o)                      % get format
%             ok = format(o,'#TDK01')              % supports(format(o),{'#TDK01'})
%             ok = format(o,{'#TDK01','#TDK02'})   % supports(format(o),{'#TDK01'})
%
%          See also DANA, DANAOBJ
%
   fmt = get(o,'format');

   if ( nargin < 2 )
      oo = fmt;                        % return format
   elseif ischar(arg2)
      ok = strcmp(fmt,arg2);
      oo = ok;                         % return OK value
   elseif iscell(arg2)
      list = arg2;                     % arg2 is a list
      ok = isequal(fmt,list);          % format contained in list?
      oo = ok;                         % return OK value
   else
      error('string or list expected for arg2!');
   end             
end   

