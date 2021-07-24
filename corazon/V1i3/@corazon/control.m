%
% CONTROL   Deal with shell control settings
%
%    Shell control settings determine the behavior of the shell. Mind that
%    method CONTROL does either manipulate object options (if output arg
%    is assigned to an object) or it directly manipulates the control set-
%    tings (if no out args are provided and more than 1 input arg).
%
%       control(o)                     % display all control settings
%       bag = control(o)               % get bag of control options
%       o = control(o,bag)             % init control options
%
%       value = control(o,tag)         % get a control option
%       control(o,tag,value)           % set a control setting
%       o = control(o,tag,value)       % set a control option
%
%    Conditional setting or providing default values
%
%       value = control(o,{tag,default}) % get a control option
%       control(o,{tag},value)           % provide a control setting
%       o = control(o,{tag},value)       % provide a control option
%
%    Example:
%       control(o,'refresh',cblist)    % set refresh callback
%       control(o,'current',2)         % set current object index
%       control(o,'dynamic',true)      % enable dynamic shell
%       control(o,'launch',func)       % set launch function
%
%    Note: to set a control option unconditionally first clear the option
%    and then set it.
%
%       o = control(o,'launch','');    % clear launch function
%       o = control(o,'launch',func);  % set launch function
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON
%
