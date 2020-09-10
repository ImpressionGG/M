function [Vx,Vy,Vr,Vset] = matrix(V,arg2,arg3,arg4)
%
% MATRIX   Get matrix-aligned data (x-, y- and radial) of a 2D vector set
%
%             matrix([m n])                      % setup matrix dimensions
%             [m,n] = matrix                     % retrieve matrix dimensions
%             m_n = matrix                       % retrieve matrix dimensions
%
%             [Vx,Vy,Vr,Vset] = matrix(V)        % get matrix alligned data and vector set
%                                                % same as [Vx,Vy,Vr,Vset] = matrix(V,'BLU') 
%             [Vx,Vy,Vr,Vset] = matrix(V,'BLR')  % matrices by order bottom-left/right
%             [Vx,Vy,Vr,Vset] = matrix(V,'BLU')  % matrices by order bottom-left/up
%             [Vx,Vy,Vr,Vset] = matrix(V,'TLR')  % matrices by order top-left/right
%             [Vx,Vy,Vr,Vset] = matrix(V,'TLD')  % matrices by order top-left/down
%
%             [Vx,Vy,Vr,Vset] = matrix(V,k)      % each k-th point in x- and y-direction
%             [Vx,Vy,Vr,Vset] = matrix(V,[m n])  % get matrix alligned data and vector set
%
%          Specifying order
%
%             [Vx,Vy] = matrix(V,order)          % get matrix alligned data and vector set
%             [Vx,Vy] = matrix(V,order,m,n)      % also specify sizes
%
%          where 'order' can be:
%
%             order = 'BLU'    % bottom-left/up order
%             order = 'BLR'    % bottom-left/right order
%             order = 'TLD'    % top-left/down order
%             order = 'TLR'    % top-left/right order
% 
%          Some call for generating test data
%
%             [Vx,Vy,Vset] = matrix('#',m,n)     % create orthogonal raster matrix
%             [Vx,Vy,Vset] = matrix('#BLR',m,n)  % BLR ordered orthogonal raster matrix
%             [Vx,Vy,Vset] = matrix('#BLU',m,n)  % BLR ordered orthogonal raster matrix
%             [Vx,Vy,Vset] = matrix('#TLR',m,n)  % BLR ordered orthogonal raster matrix
%             [Vx,Vy,Vset] = matrix('#TLD',m,n)  % BLR ordered orthogonal raster matrix
%             [Vx,Vy,Vset] = matrix('test',m,n)  % create test matrices
%
%             [Vx,Vy,Vset] = matrix('BLR',m,n)   % bottom-left/right order
%             [Vx,Vy,Vset] = matrix('BLU',m,n)   % bottom-left/up order
%             [Vx,Vy,Vset] = matrix('TLR',m,n)   % top-left/right order
%             [Vx,Vy,Vset] = matrix('TLD',m,n)   % top-left/down order
%
%           See also: ROBO REORDER

% Change history
%    2009-11-29 support 'create test matrices' (Robo/V1k)
%    2009-12-05 provide order spec (BLR,BLU,TLR,TLD) (Robo/V1k)
%    2009-12-05 extend test data generation (BLR,BLU,TLR,TLD) (Robo/V1k)
%    2009-12-05 introduce order specs (BLR,BLU,TLR,TLD) (Robo/V1k)

   global MatrixRows MatrixColumns
   
% If nargin == 0 the calling syntax applies to:
%    [m,n] = matrix     % retrieve matrix dimensions
%    m_n = matrix       % retrieve matrix dimensions
   
   if ( nargin == 0 )
      if ( nargout <= 1 )
         Vx = [MatrixRows, MatrixColumns];
      else
         Vx = MatrixRows;  Vy = MatrixColumns;
      end
      return
   end

% If nargin == 1 the calling syntax applies to:
%    matrix([m n])      % setup matrix dimensions
% or
%    [Vx,Vy,Vr,Vset] = matrix(V)
% get matrix alligned data and vector set

   if ( nargin == 1 )
      if ( all(size(V)==[1 2]) )
         MatrixRows = V(1);  MatrixColumns = V(2); 
      else
         [Vx,Vy,Vr,Vset] = matrix(V,'BLU'); % 2009-12-05 introduce order specs (BLR,BLU,TLR,TLD) (Robo/V1k)
      end
      return
   end


% If nargin == 3 the calling syntax applies to test matrix creation:
%    [Vx,Vy,Vset] = matrix('#',m,n)     % create orthogonal raster matrix
%    [Vx,Vy,Vset] = matrix('test',m,n)  % create test matrices
%
%    [Vx,Vy,Vset] = matrix('BLR',m,n)   % bottom-left/right order
%    [Vx,Vy,Vset] = matrix('BLU',m,n)   % bottom-left/up order
%    [Vx,Vy,Vset] = matrix('TLR',m,n)   % top-left/right order
%    [Vx,Vy,Vset] = matrix('TLD',m,n)   % top-left/down order

      % 2009-11-29 support 'create test matrices' (Robo/V1k)
      % 2009-12-05 extend test data generation (BLR,BLU,TLR,TLD) (Robo/V1k)

   if (nargin == 3)
       if (isstr(V))
           mode = V;
           m = arg2;  n = arg3;
           switch mode
           case {'#','#BLR','#BLU','#TLR','#TLD'}
              [Vx,Vy,Vr] = oraster(mode,m,n); % orthogonal raster matrix
           case {'BLR','BLU','TLR','TLD'}
              [Vx,Vy,Vr] = testdata(mode,m,n);
           case 'test'  % bottom-left/right
              [Vx,Vy,Vr] = matrix('BLU',m,n);
           otherwise
              error(['bad mode for test data generation: ',mode]);
           end
       else
          error('Test matrix creation (3 args) requires string for arg1!'); 
       end
       return
   end

% From here we can assume nargin == 2 or nargin == 4.

   if ( ~(nargin == 2 | nargin >= 4) )
       error('assertion violation: 2 or 4 args expected!');
   end

%This applies either to a calling syntax where arg2 is a non-string
%
%    [Vx,Vy,Vr,Vset] = matrix(V,k)      % each k-th point in x- and y-direction
%    [Vx,Vy,Vr,Vset] = matrix(V,[m n])  % get matrix alligned data and vector set
%
% or arg2 (order) is a string:
%
%    [Vx,Vy] = matrix(V,order)          % get matrix alligned data and vector set
%    [Vx,Vy] = matrix(V,order,m,n)      % also specify sizes
%
% First handle the case with 2 args where arg2 is non-string
%
   k = arg2;          
   if ( nargin == 2 )
      if (~isstr(k)) % 2009-12-05 provide order spec (BLR,BLU,TLR,TLD) (Robo/V1k)
         if all(size(k)==[1 2]) 
            MatrixRows = k(1);  MatrixColumns = k(2); 
            return
         end
      end
   end
   
% Now we can assume arg2 is a string   
% We expect 2 or 4 args   

   if (nargin == 4)
      m = arg3;  n = arg4;
   else
      if isempty(MatrixRows) | isempty(MatrixColumns)
         error('matrix dimensions not defined: use matrix([m n])');
      end
      m = MatrixRows;  n = MatrixColumns;
   end
   
   Vx = reshape(V(1,:),m,n);
   Vy = reshape(V(2,:),m,n);
   
   if (~isstr(k)) % 2009-12-05 extend test data generation (BLR,BLU,TLR,TLD) (Robo/V1k)
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
 
      % if nargin == 2 and 2nd arg is a string then
      % order is specified. So we have to do some work to reorder
      % 2009-12-05 provide order spec (BLR,BLU,TLR,TLD) (Robo/V1k)
      
   if (nargin == 2 | nargin == 4)
       order = k;  % 2nd arg
       if (isstr(order))  % OK - need post processing
           if (nargin < 3)
               m = MatrixRows;  n = MatrixColumns;
           else
               m = arg3;  n = arg4;
           end
           vx = Vx(:);  vy = Vy(:);
           switch order
           case 'BLR'   % bottom-left/right
              Vx = reshape(vx,n,m)';
              Vy = reshape(vy,n,m)';
           case {'BLU','test'}   % bottom-left/up
              Vx = reshape(vx,m,n);
              Vy = reshape(vy,m,n);
           case 'TLR'   % top-left/right
              Vx = reshape(vx,n,m)';
              Vy = reshape(vy,n,m)';
              Vx = Vx(m:-1:1,:);
              Vy = Vy(m:-1:1,:);
           case 'TLD'   % top-left/down
              Vx = reshape(vx,m,n);
              Vy = reshape(vy,m,n);
              Vx = Vx(m:-1:1,:);
              Vy = Vy(m:-1:1,:);
           otherwise
              error('bad mode for test data generation!');
           end
       end
   end
      
      
      
      % last actions ....
      
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

   return
   
%=========================================================================
% auxillary function

function [Vx,Vy,Vset] = testdata(mode,m,n,test)
%
% TESTDATA   Create Test matrices Vx,Vy where elements match row and column
%            indices
%
%               [Vx,Vy] = testdata(m,n)
%
   if (nargin < 4) test = 1; end
   
   x = 1:n;  y = 1:m;
   for (i=1:n)
       for (j=1:m);
          Vx(j,i) = i + test*j/10;
          Vy(j,i) = j + test*i/10;
       end
   end

   VxT = Vx';  VyT = Vy'; 
   VxM = Vx(m:-1:1,:);  VyM = Vy(m:-1:1,:);
   VxMT = VxM';  VyMT = VyM';
   
   switch mode
   case 'BLR'   % bottom-left/right
      Vset = [VxT(:),VyT(:)]';
   case 'BLU'   % bottom-left/up
      Vset = [Vx(:),Vy(:)]';
   case 'TLR'   % top-left/right
      Vset = [VxMT(:),VyMT(:)]';
   case 'TLD'   % top-left/down
      Vset = [VxM(:),VyM(:)]';
   otherwise
      error('bad mode for test data generation!');
   end
   
   return

function [Vx,Vy,Vset] = oraster(mode,m,n)
%
% ORASTER   Create orthogonal raster matrices Vx,Vy where elements match row and column
%           indices
%
%               [Vx,Vy] = oraster(m,n)
%
   switch mode
   case {'#BLR','#BLU','#TLR','#TLD'}
        [Vx,Vy,Vset] = testdata(mode(2:4),m,n,0);
   case '#'
        [Vx,Vy,Vset] = testdata('BLR',m,n,0);
   otherwise
        error(['oraster - bad mode: ',mode]);
   end
   return
   
% eof
