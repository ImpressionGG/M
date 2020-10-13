function ok = mountable(o,name)        % Is Path a Mountable Path      
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
   if ~isempty(find(name == '/')) || ~isempty(find(name == '/'))
      [dir,name,ext] = fileparts(name);
      name = [name,ext];
   end
      
   ok = (length(name)>=2) && (name(1) == '[') && (name(end) == ']') ...
      ||  (exist('carabased') == 2) && carabased(name);
end

