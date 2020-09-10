function o = trim(o,number)            % Set Basis of Rational Object  
%
% TRIM    Remove leading zeros
%
%            x = trim(o,x);            % trim mantissa
%
%         See also: RAT
%
   if (nargin == 2)
      o = Trim(o,number);
   end
end

%==========================================================================
% Add Two Mantissa
%==========================================================================

function y = Trim(o,x)                 % Remove Leading Zeros
%
% TRIM    Remove leading zeros
%
   while (length(x) > 1)
      if (x(1) == 0)
         x(1) = [];
      else
         break;
      end
   end
   y = x;
end
