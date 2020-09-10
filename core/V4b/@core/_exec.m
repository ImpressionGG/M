function exec(obj)
%
% EXEC   Execute M-file. Convenience function to call an M-file from an
%        uimenu callback. The name of the M-file is stored as userdata
%        in the uimenu referenced by second argument (cbo). First argument
%        (obj) is solely to make EXEC a SHELL method.
%
%           exec(obj)   % short hand for: eval(get(cbo('userdata')))
%
%        Typical example:
%
%           uimenu(men,'label','Call test.m','callback',call('exec'),...
%                      'userdata','test')
%
%        See also: SHELL CALL
%
   %cmd = get(cbo,'userdata');
   cmd = args(obj,1);
   eval(cmd);
   return
   
%eof