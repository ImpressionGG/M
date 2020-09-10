function [col,width,typ] = color(arg1,arg2,width)
%
% COLOR   Color setting
%
%    Use a short hand for better readability.
%
%       color = @carabull.color        % provide short hand (8 µs)
%       color = util(carabull,'color') % provide short hand (190 µs)
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
%    See also: CARABULL, UTIL

   list = {'r','g','b','c','m','y','ry','kw',...
           'ryk','rb','ck','bk','gk','yk','k','w'};

   if (nargin == 0)  % print color table
      if (nargout > 0)
         col = list;
      else
         PrintColors;
      end
      return
   end
   
   if (nargin == 1) && iscell(arg1)
      col = arg1{1};  width = arg1{2};  typ = arg1{3};
      if ischar(col)
         col = carabull.color(col);
      end
      return
   elseif (nargin == 1)
      col = arg1;
      if (isstr(col))
         [col,width,typ] = ColorParameters(col);
         return
      elseif isa(col,'double') && (length(col) == 1)
         if (col < 1)
            error('color index (arg1) must be greater than 1!');
         end
         idx = 1 + rem(col-1,length(list));
         col = list{idx};
         width = 1;   typ = '-';       % use defaults for other out args
      end
   elseif (nargin == 2 || nargin == 3)
      
      hdl = arg1;  col = arg2;
      if ~isempty(col)
         set(hdl,'color',carabull.color(col));
      end
      if (nargin == 3)
          set(hdl,'linewidth',width);
      end
      col = hdl;                 % return handle as a function value
      hold on;                   % always leave a hold state for plots
   else
      error('bad number of args!');
   end
end   

%==========================================================================
% Auxillary Functions
%==========================================================================

function PrintColors                   % Print Color Shorthands        
   fprintf('Supported color shorthands:\n');
   fprintf('   ''r''      red\n');
   fprintf('   ''g''      green\n');
   fprintf('   ''b''      blue\n');
   fprintf('   ''y''      yellow\n');
   fprintf('   ''c''      cyan\n');
   fprintf('   ''m''      magenta\n');
   fprintf('   ''k''      black\n');
   fprintf('   ''w''      white\n');

   fprintf('   ''kw''     gray\n');
   fprintf('   ''ryk''    brown\n');
   fprintf('   ''rb''     purple\n');
   fprintf('   ''bk''     dark blue\n');
   fprintf('   ''gk''     dark green\n');
   fprintf('   ''yk''     dark yellow\n');
   fprintf('   ''ry''     orange\n');
   fprintf('   ''ryy''    Gold\n');
end

function [col,width,typ] = ColorParameters(col)
   colstr = '';  typ = '';  width = 0;
   for (i=1:length(col))
      c = col(i);
      switch c
         case {'r','g','b','c','m','y','k','w'}
            colstr(end+1) = c;
         case {'R','G','B','C','M','Y','K','W'}
            colstr(end+1) = lower(c);
         case {'0','1','2','3','4','5','6','7','8','9'}
            width = width * 10 + (c + 0) - '0';
         case {'.','o','x','+','*','s','d','v','^','<','>','p','h'}
            typ(end+1) = c;
         case {'-',':','|','~'}
            typ(end+1) = c;
         otherwise                     % for unsupported characters
            colstr(end+1) = 'k';       % use black as a default
      end
   end

   %        colstr = col;              % copy to another variable
   col = [];                           % empty by default
   for (i=1:length(colstr))
      coli = colstr(i);
      switch coli     % assign RGB value for symbols
         case 'k'
            rgb = [0  0  0];           % black
         case 'm'
            rgb = [1  0  1];           % magenta
         case 'b'
            rgb = [0  0  1];           % blue
         case 'c'
            rgb = [0  1  1];           % cyan
         case 'g'
            rgb = [0  1  0];           % green
         case 'y'
            rgb = [1 1 0];             % yellow      
         case 'r'
            rgb = [1  0  0];           % red
         case 'w'
            rgb = [1  1   1];          % white
         otherwise
            rgb = [0  0   0];          % black by default
      end
      
      if isempty(col)
         col = rgb;                    % just take over 1st one
      else
         col = [col*(i-1) + rgb]/i;
      end
   end % for
   
   if isempty(col)                     % if still empty?
      col = [0 0 0];                   % default color black
   end
   if (isempty(width) || width == 0)
      width = 1;                       % default width is 1
   end
   if isempty(typ)
      typ = '-';                       % default type is '-' (solid)
   end
end