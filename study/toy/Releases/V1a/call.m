function cb = call(func)       % create callback for local function call
% 
% CALL   Create a proper callback for a menu function
%
%    Syntax
%
%       cb = call;                % to be handeled 
%       cb = call(3);             % to be handeled at stack level 3
%
%       cb = call('callback1');   % to be handeled by a specific 
%
%    If call('callback1') is invoked from an mfile with e.g. name 
%    'menu' then above statement would assign variable 'cb' with a
%    string value.
%
%       'menu(gfo,''callback1'',gcbo)'
%
%    This callback is usually used with a uimenu() call. The following
%    two statements are equivalent:
%
%       uimenu(men,'label','Test','callback',call('callback1'))
%       uimenu(men,'label','Test','callback',menu(gfo,''callback1''))
%
%    See also: CORE MENU
%
   level = 2;
   nargs = nargin;
   
   if (nargin > 0)
      if isnumeric(func)
         level = func;  nargs = 0;
      end
   end
   
   stack = dbstack;           % get calling stack 
   path = stack(level).file;      % get path of mfile name

   [p,mfile,ext] = fileparts(path);

   %mfile = handle(gfo);   

   if (nargs == 0)
      cb = [mfile,'(gfo);'];
   else
      %cb = [mfile,'(gfo,''',func,''');'];
      cb = [mfile,'(arg(gfo,[],cons(''',func,''',arg(gfo,0))));'];
   end
   return
end
