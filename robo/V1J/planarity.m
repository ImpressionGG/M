function [R,Q] = planarity(zz)
%
% PLANARITY  Calculate the residual deviations with respect to a best
%            fitting plane; 
%
%               z = [4 5 6 8; 2 3 4 5; 0 1 2 3];
%               [r,q] = planarity(z);
%
%               where:
%                  z: height matrix over xy grid
%                  q: height matrix of best fitting plane
%                  r: residual heights (r = z-q);
%

   if (nargin == 0)
      zz = [ 6  7  8  9  10
             4  5  6  8  9
             2  3  4  5  6
             0  1  2  3  4
           ];
   end
   
   [m,n] = size(zz);
   x = [n-1:-1:0];
   y = [m-1:-1:0];      
     
   xy = [];
   for (j=y)
       for (i=x)
           xy = [xy,[i;j]];
       end
   end
   
   %z = [zz(3,:), zz(2,:), zz(1,:)];
   z = zz(m:-1:1,:);  % first make it up side down
   z = z';            % then transpose
   z = z(:)';         % then make one column
   z = [z;0*z];       % then add artificial zero row

   
   C = map(xy,z,1);
   q = map(C,xy);
   r = z-q;

   zz = shuffle(x,y,z(1,:));
   rr = shuffle(x,y,r(1,:));
   qq = shuffle(x,y,q(1,:));
   
   if (nargout == 0)
      clf;
      subplot(221);
      show(x,y,z(1,:));
      title('Originale Messdaten (z)');
      %pause

      subplot(222);
      show(x,y,q(1,:));
      title('Lineare Approximation  (q)');
      %pause

      subplot(223);
      show(x,y,r(1,:));
      title('Residualer Fehler (r)');
      %pause
   
      zz = round(zz)
      qq = round(qq)
      rr = round(rr)
   else
      R = rr;
      Q = qq;
   end
   return
   
%==========================================================================

   function f = shuffle(x,y,z)
      m = length(y);  n = length(x);
      f = reshape(z,n,m);
      f = f(:,[m:-1:1]);
      f = f([n:-1:1],:);
      f = f';
      f = f(:,[n:-1:1]);
      return
      
   function show(x,y,z)
       m = length(y);  n = length(x);
       f = shuffle(x,y,z);
       f = f(:,[n:-1:1]);
       surf(x,y,f);
       shg;
       return
       
% eof   