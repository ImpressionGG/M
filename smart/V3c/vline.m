function vline(x,color)
%
% VLINE    Draw one or more vertical lines specified by vector x. 
%
%             vline([2, 3, 4]);
%             vline([2, 3, 4],'r');    % color red
%

   if ( isempty(x) ),
      return;
   end

   v = axis;

   if ( nargin >= 2 )
      plot([x(:),x(:)]',[v(3)*one(x(:)),v(4)*one(x(:))]',color);
   else
      plot([x(:),x(:)]',[v(3)*one(x(:)),v(4)*one(x(:))]');
   end

% eof
