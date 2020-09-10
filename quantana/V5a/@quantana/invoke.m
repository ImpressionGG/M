function oo = invoke(o,varargin)
%
% INVOKE   Helper method to invoke a callback function
%
%    Invoke a callback function via a package handler. Control needs to
%    be directed to the particular handler given by user data
%
%       o = invoke(o);
%
%    Example:
%
%       oo = mitem(o,'Foo',{@invoke,mfilename,@Foo,arg1,...});
%
%    See also: CALL, REFRESH
%
   if o.is(char(arg(o,1)),{'Refresh','Terminate','Ignore'})
      gamma = eval(['@',char(arg(o,1))]); % construct function handle
      oo = gamma(o);                      % dispatch to local function
   else
      oo = Invoke(o);                     % otherwise invoke callback
   end
end

%==========================================================================
% Local Functions
%==========================================================================

function oo = Invoke(o)
%
% INVOKE   Invoke a callback
%
   %expr = o.cons(mfilename,arg(o,0));
   expr = [{mfilename},arg(o,0)];
   refresh(o,expr);                    % setup refresh function properly

      % setup mouse click callback
      
   terminate(o,false);                 % clear terminatiion flag
   click(o,{@invoke,'Terminate'});     % setup mouse click callback
   
   %clc;                               % clear command line

   [gamma,oo] = Manage(o);
   %o = verbose(o);                    % setup verbose variable
   %busy(o,'execute');
   oo = gamma(oo);                     % actual invoking of callback
   %ready(o,'execute');

   control(o,'type',active(o));        % set recent active type
   click(o,{@invoke 'Refresh'});       % setup mouse click callback
end
function [gamma,oo] = Manage(o)
   args = arg(o,0);
   if length(args) == 0
      error('cannot manage empty arg list!');
   end
   func = char(args{1});
   gamma = eval(['@',func]);
   args(1) = [];
   oo = arg(o,args);
   oo = balance(oo);                   % balance object
end
function o = Terminate(o)
%
% TERMINATE   Set termination flag on keypress event
%
   terminate(o);
   click(o,{@invoke,'Refresh'});       % next mouse button click with refresh
end
function o = Ignore(o)
%
% IGNORE   Ignore keypress event
%
   %fprintf('Ignore: key pressed!\n');
end
function o = Refresh(o)
%
% REFRESH   Refresh current callback task
%
   refresh(o);
end
