%
% COLOR   Color setting
%
%    Use a short hand for better readability.
%
%       color = @corazito.color        % provide short hand (8 �s)
%       color = util(corazito,'color') % provide short hand (190 �s)
%
%    1) Substitute proper color values, or set color value according to
%    a graphics object's handle
%
%       color;              % print color table
%       cols = color;       % get list of colors
%
%       col = color(3);     % 3rd color of color list
%       col = color('n')    % 'n' denotes 'browN'
%       col = color('ya')   % average between 'y' (yellow) and 'a' (gray)
%       col = color('yya')  % average between 2 x 'y' and 1 x 'a'
%
%    2) Set color of a graphics object. This operation will always end
%    with a hold on operation (leaving a hold state for plot)
%
%       hdl = plot([0 1],[0 1]);
%       hdl = color(hdl,'g');     % set green color & hold on
%       hdl = color(hdl,'g',3);   % set green color and also linewidth = 3
%
%    3) Use of special characters: digits are interpreted as line width
%    and special characters 
%
%       [col,wid,typ] = color(colstr)  % extract color, with & type
%
%          type = '-'     % character: draw a line
%          type = 'o'     % draw a ball (no line, no stem)
%          type = '-o'    % draw a line with a ball
%          type = '|'     % draw a stem
%          type = '|o'    % draw a stem with a ball
%
%       [col,wid,typ] = color('r')      % col=[1,0,0], wid=1, typ = '-' 
%       [col,wid,typ] = color('r2(o)')  % col=[1,0,0], wid=2, typ = 'o' 
%
%    4) For compatibility also list of color attributes are allowed as
%    arg1. Attributes are passed through, and if color attribute is a
%    character it will be converted to RGB.
%
%       [col,wid,typ] = color({rgb,wid,typ})
%       [col,wid,typ] = color({'r',wid,typ})
%
%    Special color symbols:
%       'r'      Red
%       'g'      Green
%       'b'      Blue
%       'c'      Cyan
%       'm'      Magenta
%       'w'      White
%       'k'      blacK
% 
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO, UTIL
