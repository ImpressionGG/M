function result = iif(condition,ifexpr,elseexpr)
%
%  IIF   Inline if
%
%     Syntax
%
%        result = iif(condition,ifexpr,elseexpr);
%
%     Example
%
%        result = iif(x>=0,'positive','negative');
%
%     See also: CORE
%
   if (condition)
      result = ifexpr;
   else
      result = elseexpr;
   end
   
% eof
  