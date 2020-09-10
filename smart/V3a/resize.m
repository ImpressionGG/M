function resize(fig,x,y)
%
% RESIZE  Resize figure to have proper size for copy to clipboard
%
%            resize(fig)
%            resize            % fig = gcf
%            resize(fig,w,h)   % set new defaults
%
   persistent DefaultFigSize % global DefaultFigSize

   if ( isempty(DefaultFigSize) )
      DefaultFigSize = [550 350];
   end
   
   if (nargin == 0)
      fig = gcf;
   elseif (nargin == 1)
      % ok!
   elseif (nargin == 3)
      DefaultFigSize = [x(1) y(1)];
   else
      error('zero, one or three input args expected!')
   end
   
   pos = get(fig,'position');
   pos(3) = DefaultFigSize(1);
   pos(4) = DefaultFigSize(2);
   
   set(fig,'position',pos);
   figure(gcf);               % pop in front
   
% eof
   