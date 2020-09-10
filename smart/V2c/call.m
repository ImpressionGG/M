function cb = call(func)       % create callback for local function call
% 
% CALL   Create a proper callback for a menu function
%
%           cb = call('callback1');
%
%        If call() is invoked from an mfile with e.g. name 'menu' then
%        above statement would assign variable 'cb' with a string value
%
%           'menu(gcfo,''callback1'',gcbo)
%
%        This callback is usually used with a uimenu() call. The following
%        two statements are equivalent:
%
%           uimenu(men,'label','Test','callback',call('callback1'))
%           uimenu(men,'label','Test','callback',menu(gcfo,''callback1''))
%
%        See also: SHELL MENU CBSETUP CBINVOKE CBRESET
%
   stack = dbstack;           % get calling stack 
   path = stack(2).file;      % get path of mfile name

   [p,mfile,ext] = fileparts(path);

   %mfile = handle(gcfo);   
   cb = [mfile,'(gcfo,''',func,''');'];
   return

