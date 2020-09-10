function fig = gcf(o,guihdl)           % Get Current Fiigure           
%
% GCF   Get current figure handle including invisible GUI figure handles
%
%    1) Get current figure handle:
%
%        fig = gcf(o)        % similar to: fig = get(0,'CurrentFigure')
%
%    This call is similar to the call fig = get(0,'CurrentFigure') but with
%    all invisible registered GUI handles activated. This means that a
%    nonempty figure handle will be returned if either at least one figure
%    or some registered GUI is open, otherwise return empty ([]).
%
%    2) Register a GUI handle
%
%       gcf(corazita,hGui)    % register GUI handle
%
%    The GUI handle should be registered during execution of the GUI's
%    OpeningFcn.
%
%    Example 1: simple registration
%
%       function MyGuy_OpeningFcn(hObject, eventdata, handles, varargin)
%          gcf(corazita,handles.figure1);     % register GUI figure handle
%            :
%       end
%
%    Example 2: safe registration with exception handler
%
%       function MyGuy_OpeningFcn(hObject, eventdata, handles, varargin)
%          try          
%             gcf(corazita,handles.figure1);    % register GUI figure handle
%          catch             % avoid a crash if CORAZITA is not available
%          end               % try/catch allows to run GUI without CORAZITA
%           :
%       end
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO, FIGURE, PUSH, PULL
%
   if (nargin == 1)
      fig = get(0,'CurrentFigure');
      if isempty(fig)
         fig = Gcf(o);       % try to get from hidden figure handles
      end
   elseif (nargin == 2)
      GuiHandle(o,guihdl);
   else
      error('1 or 2 input args expected!');
   end
end

%==========================================================================
% Register/Manage Gui Handles
%==========================================================================

function list = GuiHandle(o,hdl)       % Manage GUI Handles            
%
% GUI-HANDLE   Add a GUI handle or return list of valid GUI handles
%
%    Syntax:
%       GuiHandle(o,hdl)               % add a GUI handle 'hdl'
%       list = GuiHandle(o)            % get list of GUI handles
%
   guilist = shelf(o,0,'guilist');     % fetch guilist from shelf

   if (nargin == 2)
      guilist{end+1} = hdl;
   elseif (nargin == 1)
      list = {};
      for (i=1:length(guilist))
         try
            hdl = guilist{i};             % get next GUI handle for test
            get(hdl,'HandleVisibility');  % has to work for a valid handle
            list{end+1} = hdl;            % copy to output list
         catch                            % catch if it did not work
         end
      end
      guilist = list;                  % update persistent GUI list
   else
      assert(0);                       % 0 or 1 input args expected
   end
   shelf(o,0,'guilist',guilist);       % store guilist back to shelf
end

%==========================================================================
% Get Current Figure Handle
%==========================================================================

function fig = Gcf(o)                  % Get current figure handle     
%
% GCF   Get current figure handle
%
%    This function seems to do a simple job and we might think that we can
%    use fig = gcf (MATLAB built-in 'gcf'). But here are the challenges:
%
%    1) If no figure is open then MATLAB builtin gcf would open a new
%    figure, which we do not want. In this case our intention is retur-
%    ning an empty matrix ([]). We will use get(0,'currentfig') instead,
%    which does the job right away.
%
%    2) GUI figure handles are by default invisible. This is intentio-
%    nally since in 99.9% of all cases we do not want that a command
%    line plot command plots into a GUI. So we have to make GUI handles
%    visible by temporary phase, which allows get(0,'currentfig') to
%    find also a GUI handle, if the GUI is the top window.
%
   handles = GuiHandle(o);                  % get list of all GUI handles
%
% activate all GUI handles, making them visible
%
   for (i=1:length(handles))
      hdl = handles{i};
      set(hdl,'HandleVisibility','on');     % make visible
   end
%
% Get current figure handle
%
   fig = get(0,'CurrentFigure');
%
% deactivate all GUI handles, making them invisible again
%
   for (i=1:length(handles))
      hdl = handles{i};
      set(hdl,'HandleVisibility','off');    % make invisible again
   end
end

