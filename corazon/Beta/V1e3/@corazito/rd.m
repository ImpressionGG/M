function y = rd(x,n)                   % Round to n digits             
%
% RD   Round to n digits
%
%         y = corazito.rd(x)           % round to 2 digits
%         y = corazito.rd(x,n)         % round to n digits
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
   base = 10^n;
   y = round(base*x) / base;
end

