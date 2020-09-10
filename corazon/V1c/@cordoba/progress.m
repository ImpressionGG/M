function o = progress(o,message,periode)
%
% PROGRESS   Display a progress message in the figure head line
%        
%    Repeated calls to PROGRESS will increment an internal counter. Once
%    counter reaches the value of period a progress message is updated in
%    the header line of current figure.
%
%    Syntax
%
%       progress(o,msg);                   % update progress message
%
%       o = progress(o,message,periode)    % init progress
%       o = progress(o,message,20)         % init, periode = 20
%       o = progress(o,message)            % init, periode = inf
%       o = progress(o);                   % done, restore saved headline
%
%    PROGRESS works with the internal state
%
%       var(o,'progress.fig')              % figure to display message 
%       var(o,'progress.savename')         % save figure name
%       var(o,'progress.count')            % periode for refreshing
%       var(o,'progress.periode')          % periode for refreshing
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORDOBA, GETLINE, EAT
%
   if (nargin == 1)                        % done, restore saved headline
      savename = o.either(var(o,'progress.savename'),'');
      set(gcf,'name',savename);
   elseif (nargin == 2) && (nargout > 0)   % initialize progress message
      o = progress(o,message,inf);
      return
   elseif (nargin == 2) && (nargout == 0)  % refresh progress message
      count = var(o,'progress.count') + 1;
      o = var(o,'progress.count',count);

      periode = var(o,'progress.periode');
      periode = count;                     % overwrite
      
      if (rem(count,periode) == 0)
         if ~ischar(message)
            error('string expected for arg2');
         end
         fig = var(o,'progress.fig');   
         set(fig,'name',message);
         shg;
      end
   elseif (nargin == 3)                    % init, save actual head line
      fig = figure(o);
      o = var(o,'progress.fig',fig);   
      o = var(o,'progress.savename',get(fig,'name'));   
      o = var(o,'progress.count',0);
      o = var(o,'progress.periode',periode);
      if ischar(message)
         set(gcf,'name',message);
      end
      shg
   else
      error('1,2 or 3 input args expected!');
   end
end
