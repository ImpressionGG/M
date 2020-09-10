function vf = filter(o,arg2,arg3)
% 
% FILTER   Filter a vector set using filter modes
%          The function is controlled by options:
%
%             o = opt(o,'filter.enable',1);
%             o = opt(o,'filter.mode',9);
%             o = opt(o,'filter.window',250);   % 250 ms
%
%             Xf = filter(o,t,X)          % filtered 1D vector set
%             XYf = filter(o,t,XY)        % filtered 2D vector set
%
%             Xf = filter(o,X)            % filtered 1D vector set
%             XYf = filter(o,XY)          % filtered 2D vector set
%
%          Filter modes:
%             0:  no filter
%             1:  mean value of 3 neighbourhood, extrapolation to boundary points
%             2:  same as mode 1, applied twice
%             3:  same as mode 1, applied three times
%             6:  second order  fitting
%             7:  second order  fitting, applied twice
%             8:  second order  fitting, applied three times
%             9:  forth&back order 1 filter
%
%          Filter window is specified by ms. For 2 input args the time
%          interval is fetched from opt(o,'timing.interval'), for
%          3 input args the time interval is calculated from the time
%          vector.
%
%          Copyright(c): Bluenetics 2020 
%
%          See also CORDOBA
% 
   %profiler('filter',1);
   iif = @o.iif;                       % need some utils
   either = @o.either;                 % need some utils
   
   if (nargin == 2)
      v = arg2;
      %dt = opt(o,{'timing.interval'},10);
      dt = 1;
   elseif (nargin == 3)
      t = arg2;  v = arg3;
%     dt = mean(sdiff(t));             % average delta-t
      dt = mean(diff(t));              % average delta-t
   else
      error('2 or 3 input args expected!');
   end
   
   if isempty(v)
      vf = [];
      %profiler('filter',0);
      return
   end
   
   [m,n] = size(v);
   if (m < n)                          % transpose if v is a flat matrix
      vf = filter(o,v')';              % after filtering transpose back 
      %profiler('filter',0);
      return
   end

   enable = either(opt(o,'filter.enable'),1);   % by default enabled
   wfilt = either(opt(o,'filter.window'),250);  % default window 250
   fmode = opt(o,'filter.type');                % default no filter
   
   fmode = iif(enable,fmode,0);                 % shut off if not enabled
   
   if (wfilt > length(v)) 
      if (min(size(v)) == 1)
         wfilt = length(v);
      else
         wfilt = size(v,2);
      end
   end

      % now calculate the filter window [ms] into a filter window in terms
      % of number of discrete signal values
   
   assert(~isempty(dt))
   assert(dt > 0);
   
   wfilt = round(wfilt / dt);
   wfilt = iif(wfilt < 1,1,wfilt);

      % perform actual filter tasks
      
   if (min(size(v)) == 1)
      V = [v,v];
      Vf = Filter1d(V,[fmode wfilt]);
      vf = Vf(:,1);
   else
      vf = Filter1d(v',[fmode wfilt])';
   end
   
   %profiler('filter',0);
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function F = Filter1d(M,mode,q)
%
% FILTER1D  One dimensional filtering of column data
%
%              M = randn(200,1);
%              F = filter1d(M,[9 15]);   % mode = 9, window = 50
%
%              F = filter1d(M,[mode, window],q);
%              F = filter1d(M);         % mode = 6, window = 6, q = 0.5
%
%           The mode(1) argument tells the function which filter mode has
%           to be used, mode(2) is the filter window (see listing below).
%
%           The argument q is an extrapolation weight for modes < 6. 
%           If q = 1 then extrapolation for boundary data is weighted as
%           maximum. 
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
         F(1:m,i) = Filter1d(M(:,i),[mode,w],q);
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
   return
end   

   
