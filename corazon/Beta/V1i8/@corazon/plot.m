%
% PLOT   CORAZON plot method. Extension of MATLAB plot function by
%        extended color strings denoting color, line width and line type
%
%           hdl = plot(o,hax,x1,y1,'r',x2,y2,'b|o',...)
%           hdl = plot(o,x1,y1,'r',x2,y2,'b|o',...)
%
%           plot(o,x,y,'r')     % same as plot(x,y,'r')
%           plot(o,x,y,'r2')    % plot(x,y) in red, line width 2
%           plot(o,x,y,'r2.-')  % red, line width 2, solid and dot
%           plot(o,x,y,'r|o')   % red stems and balls
% 
%        Multiple argument tupels:
% 
%           cbplot = @plot(o)   % short hand
%           cbplot(x1,y1,'r|o',x2,y2,x3,y3,'b2')
%           cbplot(t,x,'r|o',t,y,'g-.',t,z,'b2')
% 
%        Attribute list: instead of a character string plot attributes
%        can also be provided by list.
% 
%           plot(o,x1,y1,{rgb,lwid,ltyp},...)
% 
%           plot(o,x,y,{[1 0 0],1,'-'})    % solid red line, width 2
%           plot(o,x,y,{[1 0 0],2,'-'})    % solid red line, width 2
%           plot(o,x,y,{[1 0 0],2,'.-'})   % dashed/dotted red line
%           plot(o,x,y,{[1 0 0],'1','|o'}) % red stems and balls
% 
%        forwarded calling syntax
%
%           hdl = plot(corazon,o,{hax,x1,y1,'r',x2,y2,'b|o',...})
%           hdl = plot(corazon,o,arglist);
%
%        The attribute string can be a combination of color codes, line
%        type and line width. For the color codes and line type all the
%        characters of the MATLAB/plot function are supported:
% 
%           b     blue          .     point              -     solid
%           g     green         o     circle             :     dotted
%           r     red           x     x-mark             -.    dashdot 
%           c     cyan          +     plus               --    dashed   
%           m     magenta       *     star             (none)  no line
%           y     yellow        s     square
%           k     black         d     diamond
%           w     white         v     triangle (down)
%                                ^     triangle (up)
%                                <     triangle (left)
%                                >     triangle (right)
%                                p     pentagram
%                                h     hexagram
% 
%        In addition addition '|' and '~' characters are supported which
%        stand for stem plot ('|') and sequential color change ('~').
% 
%           plot(o,x,y,'|')     % plot stems
%           plot(o,x,y,'|o')    % plot stems with balls on top
% 
%        Color characters can be provided in multiple occurance, which
%        means averaging of the RGB values. Thus foe example the follwing
%        color codes may be used:
% 
%           kw    gray
%           ryk   brown
%           rb    purple
%           ck    dark cyan
%           bk    dark blue
%           gk    dark green
%           yk    dark yellow
%           ry    orange
%           ryy   gold
%
%        Provided options:
%           'color'                    % use as color argument
%           'grid'                     % set grid on/off
%           'hold'                     % hold on/off
%           'linewidth'                % use as linewidth
%           'title'                    % provide title
%           'xlabel'                   % provide xlabel
%           'ylabel'                   % provide ylabel
%           'subplpot'                 % subplot index vector
%
%        Example:
%           oo = opt(o,'linewidth',3, 'color', 'ryy');
%           oo = opt(o,'xlabel','X', 'ylabel','Y', 'title','X/Y Scatter');
%           oo = opt(oo,'subplot',[2 2 1]);
%           plot(o,x,y);
%
%        Special plot modes
%
%           plot(o,'Show')             % show object
%           plot(o,'Animation')        % animation of object
%           plot(o,'Basket')           % plot all objects of basket
%
%        Options:
%
%           title:           plot title  (default: '' - no title)
%           xlabel:          plot xlabel (default: '' - no xlabel)
%           ylabel:          plot ylabel (default: '' - no ylabel)
%           xscale:          x-scaling factor (default: 1)
%           yscale:          y-scaling factor (default: 1)
%
%        Copyright (c): Bluenetics 2020 
%
%        See also: CORAZON, LABEL
%
