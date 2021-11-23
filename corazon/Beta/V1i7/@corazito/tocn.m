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
%       for (i=1:o.ticn(10000)) A = magic(88); end
%       fprintf('%g us\n',o.tocn());
%
%    Example 2:
%       [ticn,tocn] = util(corazito,'ticn','tocn');
%       for (i=1:ticn(10000)) A = magic(88); end
%       fprintf('%g us\n',tocn());
%
%    Example 3:
%       [ticn,tocn] = util(corazito,'ticn','tocn');
%       for (i=1:ticn(10000)) A = magic(88); end; tocn();
%    
%    Example 4:
%       [ticn,tocn] = util(corazito,'ticn','tocn');
%       for (i=1:ticn(10000)) A = magic(88); end; tocn('A = magic(88)');
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO, UTIL, TICN
%
