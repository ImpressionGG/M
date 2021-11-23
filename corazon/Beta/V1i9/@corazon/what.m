%
% WHAT   What we see! Setup or display plot information. 
%
%    The what information is stored in the 'shell.what' settings
%
%       what(o,title,comment);        % setup 'what info'
%       what(o,title,tx1,tx2,...);    % setup 'what info'
%       what(o,o);                    % setup 'what info' using object info
%       what(o,[]);                   % reset 'what info'
%
%       what(o);                      % pop up plot info
%       pair = what(o);               % fetch plot info
%
%       o = what(o,title,texts);      % store in control options
%       o = what(o,title,tx1,...);    % store in control options
%
%    Example:
%
%       what(o,'UC Footprint',{'green: pF1,pF2','blue: rU'});
%       what(o,'UC Footprint','green: pF1,pF2','blue: rU');
%
%    See also: CORAZON, MESSAGE
%    Copyright (c): Bluenetics 2020 
%
