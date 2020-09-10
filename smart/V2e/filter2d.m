function F = filter2d(M,mode,q)
%
% FILTER2D  Two dimensional filtering of matrix data
%
%              F = filter2d(M,mode,q);
%              F = filter2d(M);         % mode = 6, q = 0.5 for mode < 6 and q = 7 else
%
%           The mode argument tells the function which filter mode has to be used
%           (see listing below).
%
%           The argument q is an extrapolation weight for modes < 6. If q = 1 then
%           extrapolation for boundary data is weighted as maximum. If q >= 6 then q 
%           specifies the window width.
%
%
%           Filter modes:
%              0:  no filter
%              1:  mean value of 3x3 neighbourhood, extrapolation to bounary points
%              2:  same as mode 1, applied twice
%              3:  same as mode 1, applied three times
%              4:  horizontal 1x3 filter operation
%              5:  vertical 3x1 filter operation
%              6:  second order surface fitting
%              7:  second order surface fitting, applied twice
%              8:  second order surface fitting, applied three times
%
%           See also: SMART DRIFT FILTER1D
%
   if (nargin == 2 | nargin == 2)
      if (length(mode) >= 2 )
         w = mode(2);
         mode = mode(1);
      else
         w=6;
      end
   end
   
   if (nargin < 2) mode = []; end
   if (nargin < 3)
      if (mode < 6) q = 0.0; else q = 6; end
   end
   
   if (isempty(mode)) mode = 6; end    % default filter mode
   
   [m,n] = size(M);
   
   if ( mode < 6 )
      if (q<0 | q>1) error('arg3 must be in the range 0..1!'); end
   end
   
% mode 0:  no filter

   if (mode == 0 )
      F = M;
      return
   end
% mode 1:  mean value of 3x3 neighbourhood, extrapolation to bounary points
   
   if (mode == 1 )
      Fh = filter2d(M,4,q);     % horizontal 1x3 filter
      Fhv = filter2d(Fh,5,q);   % vertical 3x1 filter
      
      Fv = filter2d(M,5,q);     % vertical 3x1 filter
      Fvh = filter2d(Fv,4,q);   % horizontal 1x3 filter
      
      F = (Fhv+Fvh)/2;
      
      return
   end
   
% mode 2:  same as mode 1, applied twice
   
   if (mode == 2 )
      F = filter2d(M,1,q);  % filter once
      F = filter2d(F,1,q);  % filter again
      return
   end
   
% mode 3:  same as mode 1, applied three times
   
   if (mode == 3 )
      F = filter2d(M,2,q);  % filter two times
      F = filter2d(F,1,q);  % filter again
      return
   end
   
% mode 4: horizontal 1x3 filter operation

   if (mode == 4)
      if (n < 3) error('arg0 must have at least 3 columns'); end
      
      Ml = M(:,1:n-2);   % left matrix
      Mm = M(:,2:n-1);   % middle matrix
      Mr = M(:,3:n);     % right matrix
      
         % calculate horizontal mean matrix
         
      Mh = (Ml+Mm+Mr)/3;            % horizontal mean matrix
      
      % calculate slopes at the borders

      [mm,nn] = size(Mh);      
      Sl = Mh(:,1)-Mh(:,2);         % left slope
      Sr = Mh(:,nn)-Mh(:,nn-1);     % right slope
      
         % calculate bondaries

      Bl = M(:,1)*(1-q) + (Mh(:,1)-Sl)*q;   % left boundary
      Br = M(:,n)*(1-q) + (Mh(:,nn)-Sr)*q;  % right boundary
      
      % calculate filtered matrices
         
      F = [Bl,Mh,Br];
      return
   end


% mode 5: vertical 3x1 filter operation

   if (mode == 5)  % vertical 1x3 filtering
      if (m < 3) error('arg0 must have at least 3 rows'); end
      
      Mt = M(1:m-2,:);   % top matrix
      Mc = M(2:m-1,:);   % center matrix
      Mb = M(3:m,:);     % bottom matrix
      
         % calculate vertical mean matrices
         
      Mv = (Mt+Mc+Mb)/3;            % vertical mean matrix
      
         % calculate slopes at the borders
      
      [mm,nn] = size(Mv);      
      St = Mv(1,:)-Mv(2,:);         % top slope
      Sb = Mv(mm,:)-Mv(mm-1,:);     % bottom slope
      
         % calculate bondaries

      Bt = M(1,:)*(1-q) + (Mv(1,:)-St)*q;  % top boundary
      Bb = M(m,:)*(1-q) + (Mv(mm,:)-Sb)*q; % bottom boundary

         % calculate filtered matrices
         
      F = [Bt;Mv;Bb];
      return
   end
   
% mode 6: second order surface fitting

      % our function is:
      % g(x,y) = hT(x,y) * c
      % where
      %    c = [c1 c2 ... c6]' 
      %    hT(x,y) = [x*x x*y y*y x y 1]
      %
      % Solution:
      % set G := [g(x1,y1); g(x2,y2); ..., g(xN,yN)]
      %     H := [hT(x1,y1); hT(x2,y2), ..., hT(xN,yN)]
      % and solve
      %     c = H\G      as min(||H*c - F||)
      
   if (mode == 6)
      if (m < w | n < w) error(sprintf('arg0 must be at least %g x %g!',w,w)); end

      X = ones(w,1)*((1:w)-round((w+1)/2));
      Y = X';
      one = ones(size(X));

      x = X(:);
      y = Y(:);

      F = 0*M;   % filtered data (initialize)
      Z = 0*M;   % counter (initialize)

      for (i=1:m-w+1)
         for (j=1:n-w+1)
            idx = i:i+w-1;   % i index range
            jdx = j:j+w-1;   % j index range 
            g = M(idx,jdx);
  
            G = g(:);
            H = [x.*x x.*y y.*y x y one(:)];
            cnmb = cond(H'*H);   % condition number is in a size of 50
            c = H\G;

            Fij = c(1)*X.*X + c(2)*X.*Y + c(3)*Y.*Y + c(4)*X + c(5)*Y + c(6)*one;
            F(idx,jdx) = F(idx,jdx) + Fij; 
            Z(idx,jdx) = Z(idx,jdx) + one;
         end
      end

      F = F ./ Z;

      return
   end

% mode 7: second order surface fitting, applied twice

	if (mode == 7)
   	F = filter2d(M,[6,w]);
      F = filter2d(F,[6,w]);
      return
   end

% mode 8: second order surface fitting, applied three times

   if (mode == 8)
      F = filter2d(M,[7,w]);
      F = filter2d(F,[6,w]);
      return
   end

% eof
   