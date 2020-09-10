function time = tocn(msg,digits)       % Toc for n Runs                
%
% TOCN   Extended TOC function for n runs
%
%    Supports compact loop statements for elapsed time estimation
%
%       time = gluon.tocn();        % in us
%       gluon.tocn(msg,2);          % round us to 2 digits
%       gluon.tocn(msg);            % round us to 0 digits
%
%    Use a short hand for better readability.
%
%       tocn = @gluon.tocn          % provide short hand (8 us)
%       tocn = util(gluon,'tocn')   % provide short hand (190 us)
%
%       time = gluon.tocn();        % in us
%       tocn('A = magic(88)',2);       % round us to 2 digits
%       tocn('A = magic(88)');         % round us to 0 digits
%
%    Example 1:
%       [ticn,tocn] = util(gluon,'ticn','tocn');
%       for (i=1:ticn(10000)) A = magic(88); end
%       fprintf('%g us\n',tocn());
%
%    Example 2:
%       [ticn,tocn] = util(gluon,'ticn','tocn');
%       for (i=1:ticn(10000)) A = magic(88); end; tocn();
%    
%    Example 3:
%       [ticn,tocn] = util(gluon,'ticn','tocn');
%       for (i=1:ticn(10000)) A = magic(88); end; tocn('A = magic(88)');
%
%    See also: GLUON, UTIL, TICN
%
   t = toc;                            % capture toc time
   [~,n] = gluon.ticn;              % get n which was in use
   t = t/n * 1e6;                      % time [us}
   
   if (nargin < 1)
      msg = 'elapsed time';
   end
   if (nargin < 2)
      digits = 0;
   end
   
   if (nargout == 0)
      fprintf('   %s: %g us\n',msg,gluon.rd(t,digits));
   else
      time = t;
   end
end
