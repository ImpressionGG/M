function [oo,hax] = subplot(o,varargin)
%
% SUBPLOT   Select subplot - handle dark mode (optional grid), always set
%           axes hold mode (if hold is not desired, explicitely call hold 
%           off). Axes handle can be retrieved by hax = axes(oo).
%
%              oo = subplot(o,311);
%              oo = subplot(o,3,1,1);
%              oo = subplot(o,[3 1 1]);
%
%           Also retrieve axes handle:
%
%              oo = subplot(o,sub);         % standard call of subplot
%              hax = axes(oo);              % get axes handle of subplot
%              [oo,hax] = subplot(o,311);   % same same
%           
%           Note that in earlier CORAZON versions axes handle has been 
%           returned directly (hax = subplot(o,...)), while this behavior 
%           is discontinued with CORAZON V1i, and axes handle is returned 
%           as part of the returned output object.
%
%           The corazon/subplot method handles also a four number indexing
%           vector, where the latter two have the role of 2-dimensional 
%           actual subplot indices.
%
%              oo = subplot(o,3223);        % same as subplot(326)
%              oo = subplot(o,3,2,2,1);     % same as subplot([3,2,4])
%              oo = subplot(o,[3 2 2 1]);   % same as subplot(3,2,4)
%
%           The conversion formula from (i,j) to k is: k = (i-1)*n + j
%
%           subplot can be used to setup an axis in semi or double
%           logarithmic plot mode, which affects all subsequent plot(o,...)
%           calls.
%
%              subplot(o,sub,'linear')      % linear mode
%              subplot(o,sub,'semilogx')    % logarithmic x, linear y
%              subplot(o,sub,'semilogy')    % logarithmic y, linear x
%              subplot(o,sub,'loglog')      % logarithmic x  and y
%
%           A call to subplot(o) at the end of a plot sequence refreshes
%           dark mode for theaxes object and draws grid if enabled
%
%              subplot(o)                   % refresh dark mode & show grid
%
%           Retrieve subplot indizes (only working if subplot has been set
%           using this method!)
%
%              sub = subplot(o)           
%
%           Copyright(c): Bluenetics 2020
%
%           See also: CORAZON, PLOT, CLS, GRID, DARK
%
   oo = o;
   if (nargin >= 2)
      sub = varargin{1};               % short hand
   else
      sub = [];
   end
   
      % dispatch arg list
      
   if (nargin == 1 && nargout == 0)
      dark(o,'Axes');                  % refresh dark mode of subplot
      grid(o);
      idle(o);                         % time to refresh graphics
      hax = o.either(axes(o),gca);
   elseif (nargin == 1 && nargout > 0)
      hax = shelf(o,gca,'subplot');
      oo = axes(o,hax);
      return
   elseif (nargin == 2 && length(sub) == 1)
      sub = sprintf('%g',sub);
      m = double(sub(1)-'0');
      n = double(sub(2)-'0');
      i = double(sub(3)-'0');
      if (length(sub) >= 4)
         j = double(sub(4)-'0');
         k = (i-1)*n + j;
         hax = subplot(m,n,k);
         sub = sub(1:4);
      else
         hax = subplot(m,n,i);
         if (m == 1 && n == 1)
            axis on;
         end
         [m,n,k,sub] = Index([m,n,i]);
      end
      
      oo = axes(o,hax);
      shelf(o,hax,'subplot',sub);
      dark(o,'Axes');
   elseif (nargin == 2 && length(sub) >= 3)
      [m,n,k sub] = Index(sub);
      hax = subplot(m,n,k);
      oo = axes(o,hax);

      shelf(o,hax,'subplot',sub);
      dark(o,'Axes');
   elseif (nargin == 3)
      [oo,hax] = subplot(o,varargin{1});
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
         otherwise
            error('bad mode (arg3)');
      end
   elseif (nargin >= 4)
      [m,n,k,sub] = Index(varargin);
      hax = subplot(m,n,k);
      oo = axes(o,hax);
      
         % store subplot ID in axes' shelf
         
      shelf(o,hax,'subplot',sub);
      dark(o,'Axes');
   end
   
      % always axis on, hold on!
      
   axis(hax,'on');
   hold(hax,'on');
   oo = opt(oo,'subplot',sub);
end

%==========================================================================
% Helper
%==========================================================================

function [m,n,k,sub] = Index(sub)
   j = [];
   if ischar(sub)
      sub = double(sub-'0');
   end
   
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
   
   if isempty(j)
      i = ceil(k/n);
      j = k -(i-1)*n;
   end
   sub = [m,n,i,j];
end
