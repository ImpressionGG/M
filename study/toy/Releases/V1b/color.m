function col = color(arg1,arg2,width)
%
% COLOR   Color setting
%
%    Substitute proper color values, or set color value according to
%    a graphics object's handle
%
%       color;              % print color table
%       cols = color;       % get list of colors
%
%       col = color('n')    % 'n' denotes 'browN'
%
%       hdl = plot([0 1],[0 1]);
%       hdl = color(hdl,'g');     % set green color 
%       hdl = color(hdl,'g',3);   % set green color and also linewidth = 3
%
%    See a convinient syntax for an easy plot including color and
%    line width setting:
%
%       color(plot(x,y),'r',3);       % to plot a line
%       color(plot(x,y,'o'),'r',3);   % to plot balls
%
%    Special color symbols:
%       'r'      Red
%       'g'      Green
%       'b'      Blue
%       'c'      Cyan
%       'm'      Magenta
%       'y'      dark Yellow      
%       'w'      White
%       'k'      blacK
%       'a'      grAy
%       'u'      Ultra marine
%       'v'      Violet
%       'o'      Orange
%       'p'      Purple
%       'd'      Dark green
%       'n'      browN
% 
%    See also: CORE, PLOT

   if (nargin == 0)  % print color table
      if (nargout > 0)
         col = {'k','a','n','p','v','m','u','b', ...
                'c','g','d','z','y','o','r','w'};
      else
         fprintf('Supported color shorthands:\n');
         fprintf('   ''k''      blacK\n');
         fprintf('   ''a''      grAy\n');
         fprintf('   ''n''      browN\n');
         fprintf('   ''p''      Purple\n');
         fprintf('   ''v''      Violet\n');
         fprintf('   ''m''      Magenta\n');
         fprintf('   ''u''      Ultra marine\n');
         fprintf('   ''b''      Blue\n');

         fprintf('   ''c''      Cyan\n');
         fprintf('   ''g''      Green\n');
         fprintf('   ''d''      Dark green\n');
         fprintf('   ''z''      dark Yellow\n');
         fprintf('   ''y''      Yellow\n');
         fprintf('   ''o''      Orange\n');
         fprintf('   ''r''      Red\n');
         fprintf('   ''w''      White\n');
      end
      return
   end
   
   if (nargin == 1)
      col = arg1;
      if (isstr(col))
         switch col   % assign RGB value for symbols
            case 'k'
               col = [0  0  0];      % black
            case 'a'
               col = [0.5 0.5 0.5];  % grAy
            case 'n'
               col = [0.6 0.4 0.2];  % browN
            case 'p'
               col = [0.8  0 0.2];   % purple
            case 'v'
               col = [0.7  0 0.7];   % violet
            case 'm'
               col = [1  0  1];      % magenta
            case 'u'
               col = [0  0 0.7];     % ultra marine
            case 'b'
               col = [0  0  1];      % blue
            case 'c'
               col = [0  0.7 0.7];   % cyan
            case 'g'
               col = [0  1  0];      % green
            case 'd'
               col = [0  0.8   0];   % dark green
            case 'z'
               col = [1 0.8 0];      % dark yellow      
            case 'y'
               col = [1 1 0];        % yellow      
            case 'o'
               col = [1  0.6 0];     % orange
            case 'r'
               col = [1  0  0];      % red
            case 'w'
               col = [1  1   1];     % white
         end
      end
      
   elseif (nargin == 2 || nargin == 3)
      
      hdl = arg1;  col = arg2;
      set(hdl,'color',color(col));
      if (nargin == 3)
          set(hdl,'linewidth',width);
      end
      col = hdl;    % return handle as a function value
   else
       
      error('bad number of args!');
      
   end
   return
end   
