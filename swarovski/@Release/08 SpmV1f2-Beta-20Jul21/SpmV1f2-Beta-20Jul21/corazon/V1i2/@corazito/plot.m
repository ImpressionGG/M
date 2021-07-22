%
% PLOT   CORAZITO PLOT method. Extension of MATLAB plot function by
%        extended color strings denoting color, line width and line type
%
%           hdl = corazito.plot(hax,x1,y1,'r',x2,y2,'b|o',...)
%           hdl = corazito.plot(x1,y1,'r',x2,y2,'b|o',...)
%
%           corazito.plot(x,y,'r')     % same as plot(x,y,'r')
%           corazito.plot(x,y,'r2')    % plot(x,y) in red, line width 2
%           corazito.plot(x,y,'r2.-')  % red, line width 2, solid and dot
%           corazito.plot(x,y,'r|o')   % red stems and balls
%
%        Dependig on the aes parameters 'XScale'  and 'YScale' corazon/plot
%        chooses either MATLAB plot, semilogx, semilogy or loglog as final
%        plot driver
%
%        Forward argument list
%
%           corazito.plot(ilist)
%           corazito.plot(ilist,'k.')  % draw 'k.' styled bullets
%
%        Multiple argument tupels:
%
%           cbplot = @corazito.plot    % short hand
%           cbplot(x1,y1,'r|o',x2,y2,x3,y3,'b2')
%           cbplot(t,x,'r|o',t,y,'g-.',t,z,'b2')
%
%        Attribute list: instead of a character string plot attributes
%        can also be provided by list.
%
%           corazito.plot(x1,y1,{rgb,lwid,ltyp},...)
%
%           corazito.plot(x,y,{[1 0 0],1,'-'})    % solid red line, width 2
%           corazito.plot(x,y,{[1 0 0],2,'-'})    % solid red line, width 2
%           corazito.plot(x,y,{[1 0 0],2,'.-'})   % dashed/dotted red line
%           corazito.plot(x,y,{[1 0 0],'1','|o'}) % red stems and balls
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
%           corazito.plot(x,y,'|')     % plot stems
%           corazito.plot(x,y,'|o')    % plot stems with balls on top
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
%           ryy   Gold
%
%        Options: An additional object can be provided as first argument
%                 to pass options
%
%           xscale:          x-scaling factor (default: 1)
%           yscale:          y-scaling factor (default: 1)
%
%        Example 1: linear plot
%
%           o = opt(corazito,'xscale',10,'yscale',0.1);
%           hdl = corazito.plot(o,hax,x1,y1,'r',x2,y2,'b|o',...)
%           hdl = corazito.plot(o,x1,y1,'r',x2,y2,'b|o',...)
%
%        Example 2: semilogarithmic plot
%
%           set(gca,'XScale','log','YScale','linear');
%           plot(corazito,x,y,'bc3-.')
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZITO,CORAZITO.COLOR,PLOT,SEMILOGX,SEMILOGY,LOGLOG
%      
