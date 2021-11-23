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
