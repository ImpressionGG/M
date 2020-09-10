function [x,y,color,rel] = points(o)
% 
% POINTS   Get points of a CARASIM object for plotting
%
%    Get x,y points and color for plotting and relative flag
%      
%       [x,y,col,rel] = points(o)      % get points, color & flag
%       plot(x,y)                      % actual plotting of points
%
%    Alternatively:
%
%       xyc = points(dp)               % vararg list for plot
%       plot(xyc{:});
%
%    See also:   CARASIM, RAMP
%
   knd = kind(o);
   dat = data(o);

   switch knd
      case 'step'
         x = dat.start + [0 dat.duration];
         level = dat.level;
         if length(level) == 1
            y = [0 level];  rel = 1;
         else
            y = [level(1) level(2)];  rel = 0;
         end
         color = '-';
         xy = {x,y,color};

      case 'pulse'
         x = dat.start + [0 0 dat.duration dat.duration];
         level = dat.level;
         if length(level) == 1
            y = [0 level level 0];  rel = 1;
         else
            y = [level(1) level(2) level(2) level(1)];  rel = 0;
         end
         color = '-';
         xy = {x,y,color};

      case 'wait'
         x = dat.start + [0 dat.duration];
         y = [0 0];  
         rel = 1;
         color = ':';
         xy = {x,y,color};

      case 'delay'
         x = dat.start + [0 dat.duration];
         y = [0 0];  
         rel = 1;
         color = '=';
         xy = {x,y,color};

      case {'chain','process'}
         seq = dat.list;

         x = 0;  y = 0;  % initialize artificial points (deleted later on!)
         xy = {};
         color = '';

         for (i=1:length(seq))
            [xi,yi,col,rel] = points(seq{i});
            color = [color,col];

            if (xi(1) == 0)
               xi = xi+x(length(x));
            end
            if (rel) yi = yi+y(length(y)); end

            x = [x xi];  y = [y yi]; 
            xyi =points(seq{i});
            xy{3*i-2} = xi;
            xy{3*i-1} = yi;
            xy{3*i-0} = col;
         end
         x(1) = [];  y(1) = [];   % delete artificial points
         x = x + dat.start;
         rel = 0;

      otherwise
         error(['bad kind: ',knd,'!']);
   end

% deal with output arguments

   if (nargout < 2)
      x = xy;
   end
end
