function [gamma,oo] = manage(o,list,varargin)
%
% MAnage   Manage function calls of local functions
%
%    Example:
%
%       function oo = foo(o,varargin)
%          [gamma,oo] = manage(o,varargin,@f1,@f2,...);
%          gamma(oo);
%          function o = f1(o)
%             scatter(rand(1,n),rand(1,arg(o,1)),'r');
%          end
%          function o = f2(o)
%             scatter(rand(1,n),rand(1,arg(o,1)),'b');
%          end
%           :
%       end
%
%    Effect: the construct will allow to invoke local functions of foo
%    by means of symbolic expressions, i.e the call oo = f1(arg(o,{1000})
%    or oo = f2(arg(o,{50})) can be symbolically invoked by
%
%       o = arg(o,{'f1',1000});        % provide an object with args
%       foo(o);                        % same as f1(arg(o,{1000}))
%
%       o = arg(o,{'f2',50});          % provide an object with args
%       foo(o);                        % same as f2(arg(o,{50}))
%
%    The same effect can be achieved by calling
%
%       foo(o,'f1',1000)               % same as f1(arg(o,{1000}))
%       foo(o,'f2',50)                 % same as f2(arg(o,{50}))
%
%    The dispatching job is done by function 'call' which manages to call
%    function foo virtually, e.g. searches along the whole class hierarchy
%    until either the original class has published function 'f1' (or 'f2')
%    or a derived class has been found with the required published funct-
%    ions
%
%    Function 'call' delegates the partial jobs to PUBLISH with the
%    following call.
%
%       list = foo(o,'?')              % return list of function handles
%
%    Remarks: with this mechanism it is also possible to write an external
%    function CALL which supports the following calling syntax:
%
%       o = gem;                       % construct a GEM object
%       call(o,{'foo','f1',1000})      % same as f1(arg(o,{1000}))
%       call(o,{'foo','f2',50})        % same as f2(arg(o,{50}))
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITA
%
   corazito.profiler('manage',1);
   [gamma,oo,name] = Gamma(o,list,varargin); % get proper gamma function
   if ~isempty(gamma)
      oo = balance(oo);
      corazito.profiler('manage',0);
      return
   end
%
% otherwise try to find a published function in the super classes
%
   stack = dbstack;
   caller = eval(['@',stack(2).name]); % fct handle of caller
%
% seek in all super classes
%
   super = superclasses(class(o));
   for (i=1:length(super))
      construct = eval(['@',super{i}]);
      oo = construct(o);               % superclass object
      
      try
         oo.tag = o.tag;               % maintain tag!
         plist = caller(oo,'?');
         [gamma,oo] = Gamma(oo,list,plist);
         if ~isempty(gamma)
            oo = balance(oo);          % not sure if this statement is good
            corazito.profiler('manage',0);
            return
         end
      catch
         'catched';
      end
   end
%
% running beyond this point is an error
%
   message = sprintf('function ''%s'' not published!',name);
   oo = work(o,'error.message',message);
   gamma = @Error;
   corazito.profiler('manage',0);
end

function oo = Error(o)
   message = work(o,'error.message');
   error(message);
end

%==========================================================================
% Get Proper Function Handle
%==========================================================================

function [gamma,oo,name] = Gamma(o,list,flist)
%
% GAMMA   Get proper function handle
%
%    Depending on the calling syntax of the calling function either a
%    gamma function is calculated which will be invoked by application
%    to a single argument. Otherwise a gamma function is returned which
%    will return the list of published functions.
%
   oo = o;                             % copy by default
   if (length(list) == 1) && isequal(list{1},'?')
      Published(flist);                % store persistent
      gamma = @Published;              % return list of function handles
      name = char(gamma);
   elseif (~isempty(list) && ~ischar(list{1}))
         gamma = flist{1};  oo = o;    % 1st function by default
         oo = arg(o,list);
         name = char(gamma);
   elseif isempty(list)
      list = arg(o,0);                 % get arg list
      
      if isempty(list)
         seeking = false;
      elseif (ischar(list{1}) || isa(list{1},'function_handle'))
         seeking = true;               % seek function
      else
         seeking = false;
      end
      
      if (seeking)
         [gamma,oo,name] = Seek(o,list,flist);  % seek gamma in class hierarchy
      else
         gamma = flist{1};  oo = o;    % 1st function by default
         name = char(gamma);
      end
   elseif isempty(list{1})
      gamma = flist{1};                % 1st function by default
      oo = arg(o,{});                  % continue with empty arg list
      name = char(gamma);
   else
      [gamma,oo,name] = Seek(o,list,flist); % seek function
   end
end

function [list,oo] = Published(list,varargin)
%
% FUNCLIST   Return the list of published functions
%
%               Published(list)        % store list in persistent variable
%               flist = Published(o)   % return list from persistent var.
%               
   persistent funclist
   
   if (nargout == 0)
      funclist = list;                 % store funct list persistent
   else
      list = funclist;                 % return gamma list from persistent
   end
   oo = [];
end
   
%==========================================================================
% Seek Function in Class Hierarchy 
%==========================================================================

function [gamma,oo,name] = Seek(o,args,flist)
%
% Split off function symbol and  try to find symbol in published list
%
   if ~iscell(args) || isempty(args)
      error('missing args - cannot continue!');
   end
   
   arguments = args;                   % save for later                      
   name = char(args{1});               % name is the function symbol
   args(1) = [];                       % remove first arg
%
% search in function list
%
   for (i=1:length(flist))
      gamma = flist{i};
      symbol = char(gamma);             % convert to function symbol
      
      idx = max(find(symbol=='/'));
      if ~isempty(idx)
         symbol = symbol(idx+1:end);
      end
      
      if isequal(name,symbol)          % function symbol found
         oo = arg(o,args);             % provide args in output object
         return                        % and tsch�ss!
      end
   end
%
% Otherwise we did not find the function. return empty args
%
   gamma = [];  oo = [];
end
