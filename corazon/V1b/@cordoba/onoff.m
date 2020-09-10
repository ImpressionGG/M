function state = onoff(o,types,clas)   % Current Type Dependent On/Off 
%
% ONOFF   Depending on type of current object return 'on' if type is
%         in typelist or 'off' otherwise.
%
%            state = OnOff(o,'bmc')          % 'on' if current type = 'bmc'
%            state = OnOff(o,{'bmc'})        % 'on' if current type = 'bmc'
%            state = OnOff(o,{'smp','pln'})  % 'on' if ... 'smp' or 'pln'
%
%         For any container object the return value is 'off'!
%         Optionally an additional class argument can be passed. In this
%         case state 'on' is only returned if also object class matches
%         the class argument.
%
%            state = OnOff(o,'bmc','cordoba')
%            state = OnOff(o,{'smp','pln'},'matcha')
%
%         Copyright(c): Bluenetics 2020 
%
%         See also: CORDOBA, SHELL, SIMPLE, BASIS
%
   oo = current(o);
   if (nargin < 3)
      clas = class(oo);
   end
   
   switch type(oo);
      case types
         if container(oo) || ~isequal(clas,class(oo))
            state = 'off';
         else
            state = 'on';
         end
      otherwise
         state = 'off';
   end
end
