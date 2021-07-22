%
% CURRENT   Get current trace object & data stream/vector
%
%    Based on contents of list of traces, object type and selection index
%    return current selected trace object.
%
%       oo = current(o)                % get current trace object
%       [oo,index] = current(o)        % get also current index
%
%       o = current(o,oo);             % update current object
%       current(o,oo);                 % push updated object into shell
%
%       oo = current(o,{oo})           % provide proper options for 'oo'
%
%    Accessing shell object:
%
%       oo = current(corazon)          % get current trace object
%       [oo,index] = current(corazon)  % get also current index
%       o = current(corazon,oo);       % update current object
%
%    Remark: depending on option 'mode.options' the options are either
%    inherited from the container object or are taken from the trace object.
%    For a fast access the call oo = current(o,oo) provides always the right
%    options. Also object args are transfered properly.
%
%    Consider the following cases:
%
%       A) Object's figure method (figure(o)) returns non-empty. In this
%       case proceed directly with 1) or 2)
%
%       B) Object's figure method (figure(o)) returns empty. In this case
%       object is replaced by shell object (o=pull(corazon)) and proceed
%       with 1) or 2).
%
%       1) Object (o) is not a container object (check with container method).
%       in this case CURRENT returns the current object.
%
%       2) Object is a container object (check with container method).
%          a) empty [] is returned if control(o,'current') is outside the
%             index range.
%          b) indexed object data(o,control(o,'current')) will be returned
%
%    Change selection (changes settings)
%
%    All these functions check if new selection differs from current
%    selection. If yes (differing) then the virtual menu function 
%    menu(o,'Current') will be invoked which usually will change set-
%    tings  and update the Trace menu. If the default functionality of 
%    menu(o,'Current') is not appropriate an overloaded function can be
%    provided to adopt for required functionality.
%
%       current(o,3)                   % set 3rd trace in list as current
%       oo = current(o,3)              % set 3rd trace current and get oo
%
%       oo = current(o,'First');       % select first object in list
%       oo = current(o,'Last');        % select last object in list
%       oo = current(o,'Next');        % select next object in list
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON
%
