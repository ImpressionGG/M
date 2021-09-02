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
