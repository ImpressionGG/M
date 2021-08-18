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
