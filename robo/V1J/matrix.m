function [Vx,Vy,Vr,Vset] = matrix(V,k)
%
% MATRIX   Get matrix-aligned data (x-, y- and radial) of a 2D vector set
%
%             matrix([m n])                     % setup matrix dimensions
%             [m,n] = matrix                    % retrieve matrix dimensions
%             m_n = matrix                      % retrieve matrix dimensions
%             [Vx,Vy,Vr,Vset] = matrix(V)       % get matrix alligned data and vector set
%             [Vx,Vy,Vr,Vset] = matrix(V,k)     % each k-th point in x- and y-direction
%             [Vx,Vy,Vr,Vset] = matrix(V,[m n]) % get matrix alligned data and vector set
%
   global MatrixRows MatrixColumns
   
   if ( nargin == 1 & all(size(V)==[1 2]) )
      MatrixRows = V(1);  MatrixColumns = V(2); 
      return
   end
   
   if ( nargin == 2 )
      if all(size(k)==[1 2]) 
         MatrixRows = k(1);  MatrixColumns = k(2); 
      end
   end
   
   
   if ( nargin == 0 )
      if ( nargout <= 1 )
         Vx = [MatrixRows, MatrixColumns];
      else
         Vx = MatrixRows;  Vy = MatrixColumns;
      end
      return
   end
   
   if isempty(MatrixRows) | isempty(MatrixColumns)
      error('matrix dimensions not defined: use matrix([m n])');
   end

   Vx = reshape(V(1,:),MatrixRows,MatrixColumns);
   Vy = reshape(V(2,:),MatrixRows,MatrixColumns);
   
   if ( nargin >= 2)
      if ~all(size(k)==[1 2]) 
         [m,n] = size(Vx);
         if ( k >= 1 )
            Vx = Vx(1:k:m,1:k:n);
            Vy = Vy(1:k:m,1:k:n);
         else
            ix = 0:(n/k-1);  ix = ix / max(ix);
            iy = 0:(m/k-1);  iy = iy / max(iy);
            
            vx = min(Vx(:)) + (max(Vx(:))-min(Vx(:)))*ix;
            vy = min(Vy(:)) + (max(Vy(:))-min(Vy(:)))*iy;
            
            Vx = ones(size(vy(:)))*vx;
            Vy = vy(:)*ones(size(vx(:)'));
         end
      end
   end
   
   Vr = sqrt(Vx.*Vx + Vy.*Vy);
   
   if ( nargout > 3 )
      [m,n] = size(Vx);
      Vset = [];
      for i=1:m
         VV = [Vx(i,:); Vy(i,:)];
         Vset = vcat(Vset,VV);
      end
      for j=1:n
         VV = [Vx(:,j)'; Vy(:,j)'];
         Vset = vcat(Vset,VV);
      end
   end
   
% eof
