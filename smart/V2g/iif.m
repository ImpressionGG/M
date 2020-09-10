function result = iif(condition,ifexpr,elseexpr)
%
%  IIF      Inline if
%
%              result = iif(condition,ifexpr,elseexpr);
%
%           Example
%
%              result = iif(x>=0,'positive','negative');
%
%           See also: SMART
%
   if (condition)
      result = ifexpr;
   else
      result = elseexpr;
   end
   
% eof
  