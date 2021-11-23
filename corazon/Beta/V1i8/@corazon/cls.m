%
% CLS   Clear screen (without destroying menus). Set background color
%       according to control option control(o,'color'). Also store axes
%       handle in output arg
%
%    Default figure = gcf:
%
%       oo = cls(o)              % figure = gcf, axes off
%       oo = cls(o,'on')         % axes visible
%       oo = cls(o,'off')        % axes invisible
%       oo = cls(o,'hold')       % set hold on
%
%    Remark: if the 'canvas' parameter of the object is non-empty
%    the 'canvas' value will be used for the canvas (backround) color.
%    Otherwise the canvas color is retrieved from control(o,'color').
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, SHG
%
