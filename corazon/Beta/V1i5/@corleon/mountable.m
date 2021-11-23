%
% MOUNTABLE   Is file path or name refering to a mount point directory?
%
%    Syntax:
%
%       ok = mountable(o,'[My Database]')   % mount = 1
%       ok = mountable('c:\tmp')            % mount = 0
%       ok = mountable('c:\tmp\[Dbase]')    % mount = 1
%       ok = mountable('[Dbase]\dir')       % mount = 0
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORLEON, SYNC, CARABASED
%
