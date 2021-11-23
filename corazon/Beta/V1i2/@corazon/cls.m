%
% CLS   Clear screen (without destroying menus). Set background color
%       according to control option control(o,'color').
%
%    Default figure = gcf:
%
%       cls(o)              % figure = gcf, axes off
%       cls(o,'on')         % axes visible
%       cls(o,'off')        % axes invisible
%       cls(o,'hold')       % set hold on
%
%    Remark: if the 'canvas' parameter of the object is non-empty
%    the 'canvas' value will be used for the canvas (backround) color.
%    Otherwise the canvas color is retrieved from control(o,'color').
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, SHG
%
