function [cmd,obj,list,func] = dispatch(obj,arg2,arg3,arg4)
%
% DISPATCH   Easy dispatching for a menu handler function
%
%    This method allows easy dispatching for a menu handler.
%
%       translator = {{'@','CbExecute'}};
%       [cmd,obj] = dispatch(obj,varargin,translator,'CbDefault');
%
%    Assume a menu handler function 'demo' which is called with the
%    following calling syntax:
%
%       1) demo(arg(obj,{'foo'}))
%       2) demo(arg(obj,{'exec1','foo'}))
%       3) demo(arg(obj,{'@foo'}))
%       4) demo(arg(obj,{'#foo'}))
%       5) demo(arg(obj,{'foo',17.3,'abc'}))
%       6) demo(arg(obj,{'@foo',5.2,'xyz'}))
%       7) demo(arg(obj,{'#foo',5.2,'xyz'}))
%       8) demo(arg(obj,{''}))
%
%    The sequence
%
%       function demo(obj)
%       %
%          trans = {{'@','exec1},{'#','exec2}};
%          [cmd,obj] = dispatch(obj,'analyse',trans,'CbSetup');
%          eval(cmd)
%          return
%       %
%
%    will effectively end-up in the following calling sequences
%
%       1) foo(obj);
%       2) exec1(arg(obj,'foo'))
%       3) exec1(arg(obj,'foo'))   % '@' resolves in exec1(...)
%       4) exec2(arg(obj,'foo'))   % '#' resolves in exec2(...)
%       5) foo(arg(obj,{17.3,'abc'}));
%       6) exec1(arg(obj,{'foo',17.3,'abc'}));
%       7) exec2(arg(obj,{'foo',17.3,'abc'}));
%       8) CbDefault(obj);
%
%    Demo/test call:
%
%       dispatch(shell,NaN);   % will cause a demo/test run
%
%    Use the following sequence:
%            
%       cmd = dispatch(obj,'analyse');
%       eval(cmd);
%
%    or in a more universal notation:
%
%       cmd = dispatch(obj,mfilename);
%       eval(cmd);
%
%    The compact calling syntax would be:
%
%    See also: CORE MENU REFRESH
%
   tag = '';  translators = {};    % by default
   
   if (nargin == 2)
      if ~iscell(arg2)    % ISNAN function would crash if applied to a list
         if (isnan(arg2))
            rundemos(obj);
            return
         end
      end
      
      if ~iscell(arg2)
         if ischar(arg2)
            fprintf('*** dispatch: obsolete call with mfilename instead of varargin\n');
         else
            error('varargin list expected for arg2');  
         end
      else
         if length(arg2) > 0
            obj = arg(obj,[],arg2);       % use varargin as argument list
         end
      end
   end

   if (nargin >= 3)
      translators = arg3;
      if ~iscell(arg2)
         if ischar(arg2)
            fprintf('*** dispatch: obsolete call with mfilename instead of varargin\n');
         else
            error('varargin list expected for arg2');  
         end
      else
         if length(arg2) > 0
            obj = arg(obj,[],arg2);       % use varargin as argument list
         end
      end
   end

   if (nargin < 4)
      arg4 = '';
   end

      % now all the input args are processed. We need to get the arg list
      % and need to extract func and list from arglist.
   
   arglist = arg(obj);                            % get arglist
   [func,mob,list] = arg(arg(core,[],arglist));   % split into func & list

      % usually func and list are extracted from arglist which is coming
      % via args from the userdata of the menu item callback. On refresh
      % or after clone this arglist might not be set and an error might
      % occur. To prevent this error the following sequence will provide
      % a recovery

   tag = '';        % @@@@@@@@@@@ set empty, don't want this code again
   if ~isempty(tag)
      parameter = ['shell.',tag,'.arglist'];
      if isempty(func)
         arglist = setting(parameter);               % get arglist
         [func,mob,list] = args(arg(shell,arglist)); % split into func&list
      else
         setting(parameter,arglist);
      end
   end

      % In case that the function is empty there is a chance that a
      % default function is provided (as arg4). If provided we compose
      % a call with the default function (like 'CbSetup(obj)'), otherwise
      % we return an empty command.

   if isempty(func)
      if isempty(arg4)
         cmd = '';  func = '';
      else
         func= arg4;
         cmd = [func,'(obj)'];
      end
      return;
   end   

      % Now func and list should have proper values. We need to check
      % whether a special character is provided to func which requires
      % an additional indirection for the launch

   for (i=1:length(translators))
      entry = translators{i};
      sch = entry{1};                       % special character
      if (sch == func(1))                   % special processing
         list = arglist;
         list{1} = func(2:end);             % modified arglist
         obj = arg(obj,[],list);
         func = entry{2};
         cmd = [func,'(obj);'];             % launch command
         return
      end
   end

      % now everything is resolved. We can update the object with the
      % proper arguments and we can prepare the proper command (cmd) 
      % that should be used for the launch.

   obj = arg(obj,[],list);
   cmd = [func,'(obj);'];     % construct callback

   return
   
%=======================================================================
% Demo & Test
%=======================================================================
   
function demo(obj)
%
% DEMO    Demo to test DISPATCH method
%
   [cmd,obj] = dispatch(obj,'demo',{{'@','exec1'},{'#','exec2'}});
   eval(cmd);
   return;
   
function foo(obj)
%
% FOO     Some dummy function
%
   arglist = args(obj);
   fprintf('  FOO:\n');
   arglist
   return
   
function exec1(obj)
%
% EXEC1   Execution function 1
%
   [func,obj,list] = args(obj);
   cmd = [func,'(obj);'];   
   fprintf('EXEC1:\n');
   eval(cmd);
   return

function exec2(obj)
%
% EXEC2   Execution function 2
%
   [func,obj,list] = args(obj);
   cmd = [func,'(obj);'];   
   fprintf('EXEC2:\n');
   eval(cmd);
   return
   
%
%=======================================================================
% Run Demos
%=======================================================================
   
function rundemos(obj)
%
% DEMO    Demo to test DISPATCH method
%
   demo(arg(obj,'foo'));              % foo(obj);
   demo(arg(obj,'exec1','foo'));      % exec1(arg(obj,'foo'))
   demo(arg(obj,'@foo'));             % exec1(arg(obj,'foo'))
   demo(arg(obj,'#foo'));             % exec2(arg(obj,'foo'))
   demo(arg(obj,'foo',17.3,'abc'));   % foo(arg(obj,{17.3,'abc'}));
   demo(arg(obj,'@foo',pi,'xyz'));    % exec1(arg(obj,{'foo',pi,'xyz'}));
   demo(arg(obj,'#foo',pi,'p','q'));  % exec2(arg(obj,{'foo',pi,'p','q'}));
   return
   
% eof