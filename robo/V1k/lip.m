function w = lip(V,W,v)
%
% LIP       Linear interpolation
%
%              w = lip(V,W,v)    linear interpolation
%
%           Note:
%
%              lip(V,W,V(:,i)) == W(:,i) !!!
%
%           and
%
%              lip(V,A*V,v) == A*v !!!
%
%           See also: ROBO, VPLT
%
   if (nargin ~= 3)
      error('3 input args expected!')
   end
   
   if any(size(V)~=size(W))
      error('Sizes of arg1 and arg2 must match!');
   end
   
   if size(V,1)~= 2
      error('arg1 and arg2 must be 2D vectors!');
   end
   
   if size(v,1)~= 2
      error('arg3 must be a 2D vector!');
   end

   vx = V(1,:);  vy = V(2,:);
   wx = W(1,:);  wy = W(2,:);
   
% Try to find periodicity 

   idx = find(vx == vx(1));

   m = length(idx);          % row size of Vx matrix
   n = round(length(vx)/m);   % column size of Vx matrix
   
   if (m*n ~= length(vx))
      error('bad structure(1) of arg1 - cannot proceed!');
   end
   
% reconstruct matrix of x- and y-coordinates

   if max(diff(idx)) <= 1
      Vx = reshape(vx,m,n);
      Vy = reshape(vy,m,n);
      Wx = reshape(wx,m,n);
      Wy = reshape(wy,m,n);
   else
      Vx = reshape(vx,n,m);  Vx = Vx';
      Vy = reshape(vy,n,m);  Vy = Vy';
      Wx = reshape(wx,n,m);  Wx = Wx';
      Wy = reshape(wy,n,m);  Wy = Wy';
   end
   
% now sort by ascending order - check later!
   
   [ans,idx] = sort(Vx(1,:));
   Vx = Vx(:,idx);  Vy = Vy(:,idx);
   Wx = Wx(:,idx);  Wy = Wy(:,idx);
   
   [ans,idx] = sort(Vy(:,1));
   Vx = Vx(idx,:);  Vy = Vy(idx,:);
   Wx = Wx(idx,:);  Wy = Wy(idx,:);
   
   vx = Vx(1,:);  vy = Vy(:,1)';
   
% check for proper Vx and Vy structures
   
   if ~all(all(Vx==ones(size(Vx,1),1)*vx))
      error('bad structure(2) of arg1 - cannot proceed!');
   end
   
   if ~all(all(Vy==vy'*ones(1,size(Vy,2))))   
      error('bad structure(3) of arg1 - cannot proceed!');
   end
   
   if any(diff(vx)<0) | any(diff(vy)<0)
      error('bad structure(4) of arg1 - cannot proceed!');
   end
   
   if any(size(Vx)~=[m,n]) |any(size(Vy)~=[m,n])|any(size(Wx)~=[m,n])|any(size(Wy)~=[m,n])
      error('bug!');
   end
   
% ok - we succeded in preparations and may start to do interpolation ...
   
   x = v(1,:);  y = v(2,:);
   
% match matrices   

   Mx = x'*ones(size(vx)) >= ones(size(x'))*vx;
   My = ones(size(vy'))*y >= vy'*ones(size(y));
   
% lower indices
   
   ix1 = sum(Mx'); iy1 = sum(My);    
   
% index corrections   

   idx = find(ix1 < 1);  if (~isempty(idx)) ix1(idx) = 0*idx+1; end
   idx = find(iy1 < 1);  if (~isempty(idx)) iy1(idx) = 0*idx+1; end
   
% upper indices
   
   ix2 = ix1 + 1;
   iy2 = iy1 + 1;
   
% index corrections   
   
   idx = find(ix2 > n);  
   if (~isempty(idx)) 
      ix2(idx) = 0*idx+n;  ix1 = ix2 - 1;
   end
   
   idx = find(iy2 > m);
   if (~isempty(idx)) 
      iy2(idx) = 0*idx+m;  iy1 = iy2 - 1;
   end
   
   vx1 = vx(ix1);  vx2 = vx(ix2);
   vy1 = vy(iy1);  vy2 = vy(iy2);

   wx11 = Wx(m*(ix1-1)+iy1);
   wx12 = Wx(m*(ix1-1)+iy2);
   wx21 = Wx(m*(ix2-1)+iy1);
   wx22 = Wx(m*(ix2-1)+iy2);
   
   wy11 = Wy(m*(ix1-1)+iy1);
   wy12 = Wy(m*(ix1-1)+iy2);
   wy21 = Wy(m*(ix2-1)+iy1);
   wy22 = Wy(m*(ix2-1)+iy2);
   
% calculate weights
   
   cx1 = (vx2-x) ./ (vx2-vx1);
   cx2 = (vx1-x) ./ (vx1-vx2);
   
   cy1 = (vy2-y) ./ (vy2-vy1);
   cy2 = (vy1-y) ./ (vy1-vy2);
   
   X = wx11.*cx1.*cy1 + wx21.*cx2.*cy1 + wx12.*cx1.*cy2 + wx22.*cx2.*cy2;
   Y = wy11.*cx1.*cy1 + wy21.*cx2.*cy1 + wy12.*cx1.*cy2 + wy22.*cx2.*cy2;
   
   w = [X(:), Y(:)]';
   
% eof