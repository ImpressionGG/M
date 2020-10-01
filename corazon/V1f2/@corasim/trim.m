function oo = trim(o,p)                % Trim Transfer Function         
%
% TRIM    Trim transfer function of a CORASIM object. If the system is of
%         type 'strf' or 'ztrf' then leading zeros of numerator and deno-
%         minator are removed and numerator and enominator are normalized
%         to have unit coefficient for den(1).
%
%         if system is of type 'css' or 'dss' then system is converted to 
%         numerator/denominator representation.
%
%            oo = trim(o)              % trim transfer function
%            p = trim(o,p)             % trim polynomial
%
%         Copyright(c): Bluenetics 2020
%
%         See also: CORASIM
%
   if (nargin == 1)
      oo = TrimTrf(o);
   elseif (nargin == 2)
      oo = TrimPoly(o,p);
   else
      error('1 or 2 input args expected');
   end
end

%==========================================================================
% Trim Polynomial
%==========================================================================

function p = TrimPoly(o,p)
   idx = find(p~=0);
   if isempty(idx)
      p = 0;
   else
      p = p(idx(1):end);
   end
end

%==========================================================================
% Trim Transfer Function
%==========================================================================

function oo = TrimTrf(o)
   [num,den] = peek(o);
   
      % trim numerator and denominator
     
   num = TrimPoly(o,num);
   den = TrimPoly(o,den);
   
      % normalize numerator/denominator
      
   c = den(1);
   if (c ~= 0)
      num = num/c;  den = den/c;
   end
   
      % build corasim in transfer function representation
      
   T = data(o,'T');
   oo = system(corasim,{num,den},T);
   
      % inherit all options from original object
      
   oo = inherit(oo,o);
end
