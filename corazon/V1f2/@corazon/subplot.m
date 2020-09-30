function hax = subplot(o,varargin)
%
% SUBPLOT   Select subplot - handle dark mode (optional grid)
%
%              hax = subplot(o,311);
%              hax = subplot(o,3,1,1);
%              hax = subplot(o,[3 1 1]);
%
%           The corazon/subplot method handles also a four number indexing
%           vector, where the latter two have the role of 2-dimensional 
%           actual subplot indices.
%
%              hax = subplot(o,3223);       % same as subplot(326)
%              hax = subplot(o,3,2,2,1);    % same as subplot([3,2,4])
%              hax = subplot(o,[3 2 2 1]);  % same as subplot(3,2,4)
%
%           The conversion formula from (i,j) to k is: k = (i-1)*n + j
%
%           A call to subplot(o) at the end of a plot sequence refreshes
%           dark mode for theaxes object and draws grid if enabled
%
%              subplot(o)                   % refresh dark mode & show grid
%
%           Copyright(c): Bluenetics 2020
%
%           See also: CORAZON, PLOT, CLS, GRID, DARK
%
   if (nargin >= 2)
      sub = varargin{1};               % short hand
   end
   
      % dispatch arg list
      
   if (nargin == 1)
      dark(o,'Axes');                  % refresh dark mode of subplot
      grid(o);
      idle(o);                         % time to refresh graphics
   elseif (nargin == 2 && length(sub) == 1)
      sub = sprintf('%g',sub);
      m = double(sub(1)-'0');
      n = double(sub(2)-'0');
      i = double(sub(3)-'0');
      if (length(sub) >= 4)
         j = double(sub(4)-'0');
         k = (i-1)*n + j;
         hax = subplot(m,n,k);
      else
         hax = subplot(m,n,i);      
      end
      dark(o,'Axes');
   elseif (nargin == 2 && length(sub) >= 3)
      [m,n,k] = Index(sub);
      hax = subplot(m,n,k);
      dark(o,'Axes');
   elseif (nargin >= 4)
      [m,n,k] = Index(varargin);
      hax = subplot(m,n,k);
      dark(o,'Axes');
   end
end

%==========================================================================
% Helper
%==========================================================================

function [m,n,k] = Index(sub)
   j = [];
   if iscell(sub)
      m = sub{1};  n = sub{2};  i = sub{3}; 
      if (length(sub) >= 4)
         j = sub{4};
      end
   else
      m = sub(1);  n = sub(2);  i = sub(3); 
      if (length(sub) >= 4)
         j = sub(4);
      end
   end
   
   if (length(sub) >= 4)    
      k = (i-1)*n + j;
   else
      k = i;
   end
end
