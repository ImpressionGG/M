function col = color(col)
%
% COLOR   Substitute proper color values
%
%            col = color('n')  % 'n' denotes 'browN'
%
%         Special color symbols:
%            'n'   brown
%            'y'   dark yellow
%            'a'   gray
%
%         Private function of class SMART

   if (isstr(col))
      switch col   % assign RGB value for symbols
         case 'n'
            col = [0.6 0.4 0.2];  % browN
         case 'y'
            col = [1 0.8 0];      % dark yellow      
         case 'a'
            col = [0.5 0.5 0.5];  % grAy
         case 'c'
            col = [0  0.7 0.7];   % cyan
         case 'u'
            col = [0  0 0.7];     % ultra marine
         case 'v'
            col = [0.7  0 0.7];   % violet
         case 'o'
            col = [1  0.6 0];     % orange
         case 'p'
            col = [0.8  0 0.2];   % purple
         case 'd'
            col = [0  0.8   0];   % dark green
      end
   end
   return
   
% eof      
   
