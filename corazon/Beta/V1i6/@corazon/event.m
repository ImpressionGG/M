%
% EVENT   Register an event or invoke event
%
%    1) Register an event
%
%       event(o,'Current',cblist)      % add cblist to 'Current' registry 
%       event(o,'Current',o)           % add call to current function
%
%    2) Invoke an event
%
%       event(o,'Current')             % invoke event 'Current'
%       event(arg(o,args),'Current')   % invoke event, passing args
%
%    3) Reset event registrations
%
%       event(o,{})                    % reset all events
%       event(o,{},'Current')          % reset registry for 'Current'
%
%    4) Show event registry
%
%       event(o)                       % show event registry
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, WRAP, REBUILD, CURRENT
%
