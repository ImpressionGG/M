function [n,nout] = ticn(n)            % Tic for n Runs                
%
% TICN   Extended TIC function for n runs
%
%    Supports compact loop statements for elapsed time estimation
%
%           n = corazito.ticn(1000);   % 1000 runs
%           n = corazito.ticn();       % 10000 runs
%           [~,N] = corazito.ticn();   % return persistent N value
%
%    Use a short hand for better readability.
%
%       ticn = @corazito.ticn          % provide short hand (8 �s)
%       ticn = util(corazito,'ticn')   % provide short hand (190 �s)
%
%       n = ticn(1000);                % 1000 runs
%       n = ticn();                    % 10000 runs
%       [~,N] = ticn();                % return persistent N value
%
%    Example 1:
%       [ticn,tocn] = util(corazito,'ticn','tocn');
%       for (i=1:ticn(10000)) A = magic(88); end
%       fprintf('%g us\n',tocn());
%
%    Example 2:
%       [ticn,tocn] = util(corazito,'ticn','tocn');
%       for (i=1:ticn(10000)) A = magic(88); end; tocn();
%    
%    Example 3:
%       [ticn,tocn] = util(corazito,'ticn','tocn');
%       for (i=1:ticn(10000)) A = magic(88); end; tocn('A = magic(88)');
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO, UTIL, TOCN
%
   persistent N
   
   if (nargout >= 2)
      n = N;
      nout = N;
      return
   end
      
   if (nargin == 0)
      n = 10000;
   end
   
   N = n;
   tic;
end
