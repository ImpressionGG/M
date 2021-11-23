function oo = stop(o,value)
%
% STOP   Retrieve stop flag.
%
%           flag = stop(o)             % retrieve stop flag
%           stop(o,value)              % set stop flag to value
%
%           stop(o,'Enable')           % enable stop callback for but.press
%           stop(o,'Disable')          % disable stop callback for but.press
%           stop(o,'Callback')         % handle stop callback
%
%           stop(o,'on')               % same as stop(o,'Enable')
%           stop(o,'off')              % same as stop(o,'Disable')
%
%    Stop flag is cleared by TIMER function
%    and set by butpress, if butpress properly set to Stop()
%
%    Example
%
%       timer(o,0.1);                  % set timer, clear stop flag
%       while (~stop(o))
%          % do something
%          wait(o);                    % wait for timer
%       end
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO, TIMER, TERMINATE, WAIT, PROGRESS
%
   if (nargin == 2 && ischar(value))
      switch value
         case {'Enable','on'}
            oo = Enable(o);            % enable stop for button press
         case {'Disable','off'}
            oo = Disable(o);           % disable stop for button press
         case 'Callback'
            oo = Callback(o);
         otherwise
            error('bad mode');
      end
      return
   elseif (nargin == 1 && isequal(arg(o,1),'Callback'))
      oo = Callback(o);
   end
   
   if (nargin == 1)
      oo = setting(o,{'control.stop',0});
   else
      setting(o,'control.stop',value);
   end
end

%==========================================================================
% Enable/Disable Button Press
%==========================================================================

function o = Enable(o)
   stop(o,0);                          % clear stop flag
   cb = call(o,'corazon',{@stop 'Callback'});
   set(gcf,'WindowButtonDownFcn',cb);
end
function o = Disable(o)
  set(gcf,'WindowButtonDownFcn',[]);
end

%==========================================================================
% Stop Callback
%==========================================================================

function o = Callback(o)
   fprintf('*** stop by user''s button press\n');
   stop(o,1);                       % set stop flag
   Disable(o);
end

