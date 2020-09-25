function oo = trim(o)                  % Trim Transfer Function         
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
%
%         Copyright(c): Bluenetics 2020
%
%         See also: CORASIM
%
   [num,den] = peek(o);
   
      % trim numerator
      
   idx = find(num~=0);
   if isempty(idx)
      num = 0;
   else
      num = num(idx(1):end);
   end
   
      % trim denominator
      
   idx = find(den~=0);
   if isempty(idx)
      den = 0;
   else
      den = den(idx(1):end);
   end
   
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
