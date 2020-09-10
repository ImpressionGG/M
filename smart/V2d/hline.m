function hline(y,color)
%
% HLINE    Draw one or more horizontal lines specified by vector y. 
%
%             hline([2, 3, 4]);
%             hline([2, 3, 4],'r');    % color red
%
   if ( isempty(y) )  return; end

   v = axis;

   if ( nargin >= 2 )
      plot([v(1)*one(y(:)),v(2)*one(y(:))]',[y(:),y(:)]',color);
   else
      plot([v(1)*one(y(:)),v(2)*one(y(:))]',[y(:),y(:)]');
   end

% eof

