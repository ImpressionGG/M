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
%           subplot can be used to setup an axis in semi or double
%           logarithmic plot mode, which affects all subsequent plot(o,...)
%           calls. It also can activate the subplot as 'hold' 
%
%              subplot(o,sub,'linear')      % linear mode
%              subplot(o,sub,'semilogx')    % logarithmic x, linear y
%              subplot(o,sub,'semilogy')    % logarithmic y, linear x
%              subplot(o,sub,'loglog')      % logarithmic x  and y
%              subplot(o,sub,'hold')        % hold subsequent plots
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
   elseif (nargin == 3)
      subplot(o,varargin{1});
      mode = varargin{2};
      
      switch mode
         case 'linear'
            set(gca,'XScale','linear','YScale','linear');
         case 'semilogx'
            set(gca,'XScale','log','YScale','linear');
         case 'semilogy'
            set(gca,'XScale','linear','YScale','log');
         case 'loglog'
            set(gca,'XScale','log','YScale','log');
         case 'hold'
            hold on;
         otherwise
            error('bad mode (arg3)');
      end
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
