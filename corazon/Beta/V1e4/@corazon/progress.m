function progress(o,msg,percent)
%
% PROGRESS  Display progress in figure menu bar
%
%              progress(o,msg,percent) % display message with percentage
%              progress(o,msg)         % display message without percentage
%              progress(o)             % show current object
%
%           Options:
%
%              progress:               % enable/disable display (default 1)
%
%           Copyright(c): Bluenetics 2020
%
%           See also: CORAZON, TITLE
%
   fig = figure(o);
   if isempty(fig)
      fig = gcf;
   end
   
   if (nargin == 1)
      title(o);                        % always - independent of 
      return                           % progress option setting
   end
   
      % check 'progress' option and ignore if progress display is disabled
      
   if ~opt(o,{'progress',true})
      return
   end
   
      % progress display is enabled - display progress
      
   if (nargin == 2)
      set(fig,'Name',msg);
   elseif (nargin == 3)
      set(fig,'Name',sprintf('%s (%g%%)',msg,o.rd(percent,0)));
   else
      error('1,2 or 3 input args expected');
   end
   
   idle(o);                            % give time to display
end
