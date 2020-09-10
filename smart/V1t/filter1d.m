function F = filter1d(M,mode,q)
%
% FILTER1D  One dimensional filtering of column data
%
%              F = filter1d(M,mode,q);
%              F = filter1d(M);         % mode = 6, q = 0.5 for mode < 6 and q = 7 else
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
%              1:  mean value of 3 neighbourhood, extrapolation to bounary points
%              2:  same as mode 1, applied twice
%              3:  same as mode 1, applied three times
%              6:  second order  fitting
%              7:  second order  fitting, applied twice
%              8:  second order  fitting, applied three times
%              9:  forth&back order 1 filter
%
%           Remark: for SMART V1h toolbox function FILTER1D matches exactly
%                   with function ONEDFILT from DANA V1s toolbox
%
%           See also: SMART DRIFT FILTER2D

	if (nargin == 2 | nargin==3)
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
   
   if (isempty(mode)) mode = 6; w=6; end    % default filter mode
   
   [m,n] = size(M);
   
   if ( mode < 6 )
      if (q<0 | q>1) error('arg3 must be in the range 0..1!'); end
   end
   
% apply filter operation to all columns if more than one column
   
   if (n > 1)
      for (i=1:n)
         F(1:m,i) = filter1d(M(:,i),[mode,w],q);
      end
      return
   end
   
% mode 0:  no filter

   if (mode == 0 )
      F = M;
      return
   end

% mode 1:  mean value of 3 neighbourhood, extrapolation to bounary points
   
   if (mode == 1 )
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
   
% mode 2:  same as mode 1, applied twice
   
   if (mode == 2 )
      F = filter1d(M,1,q);  % filter once
      F = filter1d(F,1,q);  % filter again
      return
   end
   
% mode 3:  same as mode 1, applied three times
   
   if (mode == 3 )
      F = filter1d(M,2,q);  % filter two times
      F = filter1d(F,1,q);  % filter again
      return
   end
   
   
% mode 6: second order fitting

      % our function is:
      % g(x) = hT(x) * c
      % where
      %    c = [c1 c2 c3]' 
      %    hT(x,y) = [x*x x 1]
      %
      % Solution:
      % set G := [g(x1); g(x2); ..., g(xN)]
      %     H := [hT(x1); hT(x2), ..., hT(xN)]
      % and solve
      %     c = H\G      as min(||H*c - F||)
      
      
   if (mode == 6)
         
%      w=q; 
      if (m < w) error(sprintf('arg0 must be at least %g x 1!',w)); end

      X = (1:w)-round((w+1)/2);
      one = ones(size(X));

      x = X(:);

      F = 0*M;   % filtered data (initialize)
      Z = 0*M;   % counter (initialize)

      for (i=1:m-w+1)
         idx = i:i+w-1;   % i index range
         jdx = 1;   % j index range 
         g = M(idx,jdx);
         
         G = g(:);
         H = [x.*x x one(:)];
         cnmb = cond(H'*H);   % condition number is in a size of 50
         c = H\G;
         
         Fij = c(1)*X.*X + c(2)*X + c(3)*one;
         F(idx,jdx) = F(idx,jdx) + Fij'; 
         Z(idx,jdx) = Z(idx,jdx) + one';
      end
      F = F ./ Z;
      return
   end

% mode 7: second order surface fitting, applied twice

   if (mode == 7)
      F = filter1d(M,[6,w]);
      F = filter1d(F,[6,w]);
      return
   end

% mode 8: second order surface fitting, applied three times

   if (mode == 8)
      F = filter1d(M,[7,w]);
      F = filter1d(F,[6,w]);
      return
   end

% mode 9: forth&back order 1 filter

   if (mode == 9)
      %clrscr
      %t = 1:size(M,1);

      a = exp(-3/w);
      A = [1 -a];
      B = [0 (1-a)];
      
      Mbeg = ones(size(M,1),1) * M(1,:);
      M1 = M - Mbeg;
      
         % forward filter
         
      F1 = filter(B,A,M1) + Mbeg;
      
      Mend = ones(size(M,1),1) * M(end,:);
      M2 = M(end:-1:1,:) - Mend;

         % backward filter
         
      F2 = filter(B,A,M2);
      F2 = F2(end:-1:1,:) + Mend;
 
      F = (F1+F2)/2;   % mean of forward/backward filter
      %plot(t,M(:,1),'b', t,F(:,1),'r');shg   
      return
   end
   
% eof
   