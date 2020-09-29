function [m,n] = size(o,i)
%
% SIZE   Return sizes of a corinthian object
%
%           [m n] = size(o)
%           m_n = size(o)
%           m = size(o,1)
%           n = size(o,2)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH, DIGITS, ORDER, MATRIX
%
   switch o.type
      case 'matrix'
         [m,n] = size(o.data.matrix);
      case {'trf','number','poly','ratio'}
         m = 1;  n = 1;
      otherwise
         error('implementation');
   end
   
   if (nargin == 2)
      if (i == 1)
         n = [];
         return
      elseif (i == 2)
         m = n;
         n = [];
      else
         error('arg2 must be 1 or 2');
      end
   elseif (nargout <= 1)
      m = [m n];
   end
end