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
