function y = rd(x,n)                   % Round to n digits             
%
% RD   Round to n digits, given n is an integer. 
%
%         y = corazito.rd(x)           % round to 2 digits
%         y = corazito.rd(x,2)         % round to 2 digits
%
%         y = corazito.rd(x,0.2)       % round mantissa to 2 digits
%
%      Use a short hand for better readability.
%
%         rd = @corazito.rd            % provide short hand (8 �s)
%         rd = util(corazito,'rd')     % provide short hand (190 �s)
%
%         y = rd(x)                    % round to 2 digits
%         y = rd(x,n)                  % round to n digits
%
%      Copyright(c): Bluenetics 2020 
%
%      See also: CORAZITO, UTIL
%
   if (nargin == 1)
      n = 2;                           % default 2 digits
   end
   y = Round(x,n);
end

%==========================================================================
% Actual Rounding
%==========================================================================

function y = Round(x,n) 
   if (floor(n) == n)                  % ordinary rounding
      base = 10^n;
      y = round(base*x) / base;
   else
      while (1)
         n = n*10;
         if (floor(n) == n)
            break;
         end
      end
      
         % make positive
         
      sgn = sign(x);
      x = abs(x);
      
         % get mantissa
         
      xpo = floor(log10(x));           % base 10 exponent
      m = x/10^xpo;                    % mantissa   
         
         % round and reconstract result
         
      m = Round(m,n);
      y = sgn*10^xpo * m;
   end
end

