function Vr = reorder(V)
%
% REORDER   Reorder a 2D vector set to have points column wise instead of 
%           row wise.
%
%              Vr = reorder(V)   % reorder vector set
%
%           Note: before using REORDER the general matrix dimensions must
%                 be defined by invoking 'matrix([m n])';
%
%           See also: ROBO, MATRIX

   [m,n] = size(V);
   if ( m < 2 | m > 4 )
      error('2D, 3D or 4H vector set expected!')
   end
   
   [M,N] = matrix;   % get standard dimensions
   
% reordering is achieved by swapping dimensions and transposing!

   X = reshape(V(1,:),N,M)';
   Y = reshape(V(2,:),N,M)'; 
   
   if m >= 3 
      Z = reshape(V(3,:),N,M)'; 
   end
   
   if m >= 4
      W = reshape(V(4,:),N,M)'; 
   end
   
% create reordered vector set

   if ( m == 2 )
      Vr = [X(:),Y(:)]';
   elseif ( m == 3 )
      Vr = [X(:),Y(:),Z(:)]';
   elseif ( m == 3 )
      Vr = [X(:),Y(:),Z(:),W(:)]';
   else
      error('bug!');
   end
   
% eof
