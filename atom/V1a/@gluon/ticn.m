function [n,nout] = ticn(n)            % Tic for n Runs                
%
% TICN   Extended TIC function for n runs
%
%    Supports compact loop statements for elapsed time estimation
%
%           n = gluon.ticn(1000);      % 1000 runs
%           n = gluon.ticn();          % 10000 runs
%           [~,N] = gluon.ticn();      % return persistent N value
%
%    Use a short hand for better readability.
%
%       ticn = @gluon.ticn             % provide short hand (8 us)
%       ticn = util(gluon,'ticn')      % provide short hand (190 us)
%
%       n = ticn(1000);                % 1000 runs
%       n = ticn();                    % 10000 runs
%       [~,N] = ticn();                % return persistent N value
%
%    Example 1:
%       [ticn,tocn] = util(gluon,'ticn','tocn');
%       for (i=1:ticn(10000)) A = magic(88); end
%       fprintf('%g ?s\n',tocn());
%
%    Example 2:
%       [ticn,tocn] = util(gluon,'ticn','tocn');
%       for (i=1:ticn(10000)) A = magic(88); end; tocn();
%    
%    Example 3:
%       [ticn,tocn] = util(gluon,'ticn','tocn');
%       for (i=1:ticn(10000)) A = magic(88); end; tocn('A = magic(88)');
%
%    See also: GLUON, UTIL, TOCN
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
