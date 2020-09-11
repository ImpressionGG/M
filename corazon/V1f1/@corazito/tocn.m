function time = tocn(msg,digits)       % Toc for n Runs                
%
% TOCN   Extended TOC function for n runs
%
%    Supports compact loop statements for elapsed time estimation
%
%       time = corazito.tocn();        % in �s
%       corazito.tocn(msg,2);          % round �s to 2 digits
%       corazito.tocn(msg);            % round �s to 0 digits
%
%    Use a short hand for better readability.
%
%       tocn = @corazito.tocn          % provide short hand (8 �s)
%       tocn = util(corazito,'tocn')   % provide short hand (190 �s)
%
%       time = corazito.tocn();        % in �s
%       tocn('A = magic(88)',2);       % round �s to 2 digits
%       tocn('A = magic(88)');         % round �s to 0 digits
%
%    Example 1:
%       [ticn,tocn] = util(corazito,'ticn','tocn');
%       for (i=1:ticn(10000)) A = magic(88); end
%       fprintf('%g �s\n',tocn());
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
%    See also: CORAZITO, UTIL, TICN
%
   t = toc;                            % capture toc time
   [~,n] = corazito.ticn;              % get n which was in use
   t = t/n * 1e6;                      % time [�s}
   
   if (nargin < 1)
      msg = 'elapsed time';
   end
   if (nargin < 2)
      digits = 0;
   end
   
   if (nargout == 0)
      fprintf('   %s: %g us\n',msg,corazito.rd(t,digits));
   else
      time = t;
   end
end
