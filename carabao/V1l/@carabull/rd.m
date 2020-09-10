function y = rd(x,n)                   % Round to n digits             
%
% RD   Round to n digits
%
%         y = carabull.rd(x)           % round to 2 digits
%         y = carabull.rd(x,n)         % round to n digits
%
%      Use a short hand for better readability.
%
%         rd = @carabull.rd            % provide short hand (8 µs)
%         rd = util(carabull,'rd')     % provide short hand (190 µs)
%
%         y = rd(x)                    % round to 2 digits
%         y = rd(x,n)                  % round to n digits
%
%      See also: CARABULL, UTIL
%
   if (nargin == 1)
      n = 2;                           % default 2 digits
   end
   base = 10^n;
   y = round(base*x) / base;
end

