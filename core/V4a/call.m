function cb = call(func,mfile) 
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
%    1) If call('callback1') is invoked from an mfile with e.g. name 
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
%    2) Provided with two input arguments but arg2 being a cell array
%    a complete different functionality is provided.
%
%       obj = call(obj,{'@'})  % sets up a proper callback option
%                              % for menu creation with MITEM
%
%    Above statement is equivalent to
%
%       obj = option(obj,'callback',['@',caller(0)]);
%
%    See also: CORE, MENU, MITEM
%
   level = 2;
   nargs = nargin;
   
% Check for special call - item 2)

   if (nargin == 2)
      if iscell(mfile)
         obj = func;         % firtst arg to be treated as an object
         prefix = mfile{1};            
         func = caller(obj,1);
         obj = option(obj,'callback',[prefix,func]);
         cb = obj;
         return;
      end
   end
   
% Continue to handle the normal case (item 1)
   
   if (nargin > 0)
      if isnumeric(func)
         level = func;  nargs = 0;
      end
   end
   
   stack = dbstack;               % get calling stack 
   path = stack(level).file;      % get path of mfile name

   if (nargin < 2)
      [p,mfile,ext] = fileparts(path);
   end
   
   if (nargs == 0)
      cb = [mfile,'(gfo);'];
   else
      %cb = [mfile,'(gfo,''',func,''');'];
      %cb = [mfile,'(arg(gfo,[],cons(''',func,''',arg(gfo,0))));'];
      cb = [mfile,'(arg(gfo,cons(''',func,''',arg(gfo,0))));'];
   end
   return
end
