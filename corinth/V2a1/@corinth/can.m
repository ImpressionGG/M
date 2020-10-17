function [o1,o2] = can(o,x,y)          % Cancel Common Factors         
%
% CAN   Cancel common factors. First calculate greatest common divisor
%       (GCD) of two rational objects and then cancel by GCD (common
%       factors) 
%
%       1) Cancel common factors of two Mantissa
%
%          o = base(rat,100);
%          [x,y] = can(o,[10 71],[4 62])   % cancel two mantissa
%
%       2) Cancel internal comon factors of an Object
%
%          oo = can(o)                 % cancel object
%
%       Example 1:
%
%          o = base(rat,10);
%          [f,x,y] = gcd(o,[10 71],[4 62])   % divide two mantissa
%
%          => f = [7] (gcd), x = [51], y = [22] 
%
%       Options ('tff' type only):
%
%          eps:              cancellation epsilon (default: 1e-7)
%
%       See also: CORINTH, TRIM, FORM, GCDs
%
   if (nargin == 1)
      if isequal(work(o,'can'),1)      % object already cancelled?
         o1 = o;
         return                        % object already canceled - bye!
      end
      
      switch o.type
         case 'trf'
            o1 = CanTrf(o);
         case 'number'
            o1 = CanNumber(o);
         case 'poly'
            o1 = CanPoly(o);
         case 'ratio'
            o1 = CanRatio(o);
         case 'matrix'
            o1 = CanMatrix(o);
         otherwise
            error('implementation restriction!');
      end
      o1.work.can = true;              % object is cancelled
      
    elseif (nargin == 3)
      cf = gcd(o,x,y);                 % common factor
      
      [o1,r] = div(o,x,cf);            % cancel common factor
      assert(all(r==0));
      
      [o2,r] = div(o,y,cf);            % cancel common factor
      if ~all(r==0)
         assert(all(r==0));
      end
   else
      error('implementation restriction!');
   end
end

%==========================================================================
% Cancel Trf
%==========================================================================

function oo = OLdCanTrf(o)             % Old Cancel Transfer Function  
   oo = o;                             % just in case
   caneps = opt(o,{'eps',1e-3});
   
      % calculate numerator and denominator roots
      
   [rnum,rden] = Roots(o,1);
   dirty = 0;		     % dirty bit

   degnum = length(rnum);
   degden = length(rden);
   
   if ( degden == 0  ||  degnum == 0 ) 
      oo = o;
      return; 
   end

      % calculate distance matrix

   D = [];
   for (i = 1:degden)
      avg = abs((rnum + rden(i))/2);
      dT = abs(rnum - rden(i));
      idx = find(avg > eps);
      if ~isempty(idx)
         dT(idx) = dT(idx) ./ avg(idx);
      end
      D = [D, dT];	 % distance matrix
   end

      % prepare cancellation

   idx_den = 1:degden;  idx_num = 1:degnum;

   for (j = 1:length(rden))
      
      delta = abs(D(:,j));
      found = find( delta < caneps );  
      
      for ( k = 1:length(found) )
	      i = found(k);
         
	      if ( idx_num(i) ~= 0  &  idx_den(j) ~= 0 )
	         dirty = 1;
	         re = real(rnum(i));  im = imag(rnum(i));
	         fprintf('cancel: %g',re);
	         if ( abs(im) > eps )
	            if ( im > 0)
		            fprintf(' + i %g',im);
               else
		            fprintf(' - i %g',-im);
               end
            end
            
            % re = real(r_num(i));  im = imag(r_num(i));
	         re = real(rden(j));  im = imag(rden(j));
	         fprintf(' <--> %g',re);
	         if ( abs(im) > eps )
	            if ( im > 0)
		            fprintf(' + i %g',im);
               else
		            fprintf(' - i %g',-im);
               end
            end
	         fprintf(' (delta: %g)\n',delta(i));
	         idx_num(i) = 0;
            idx_den(j) = 0;
            break;
	      end
      end
   end

   if ( dirty ~= 0 )
      idx_num(find(idx_num == 0)) = [];
      idx_den(find(idx_den == 0)) = [];

         % K factor

      if ( all(num == 0)  &  all( den == 0 ) )
	      K = NaN;
      elseif ( all(num == 0) )
	      K = 0;
      elseif ( all(den == 0) )
	      K = inf;
      else
	      if ( degnum <= degden )
	         [ans1,ans2,K] = tf2zp(num,den);   % get gain K
         else
	         [ans1,ans2,K] = tf2zp(den,num);   % get gain K
	          K = 1/K;
         end
      end

         % new numerator and denominator

      [num,den] = zp2tf(rnum(idx_num),rden(idx_den),K);

      if ( length(num) == 0 ) num = 1; end	   % V1.0a
      if ( length(den) == 0 ) den = 1; end	   % V1.0a

         % new K factor (K1)

      if ( all(num == 0)  &  all( den == 0 ) )
	      K1 = NaN;
      elseif ( all(num == 0) )
	      K1 = 0;
      elseif ( all(den == 0) )
	      K1 = inf;
      else
	      if ( degnum <= degden )
	         [ans1,ans2,K1] = tf2zp(num,den);   % get gain K
         else
	         [ans1,ans2,K1] = tf2zp(den,num);   % get gain K
	         K1 = 1/K1;
	      end
      end
      
      num = K/K1*num;
   end
   
      % normalize to denominator coefficien
      
   cn = den(1);
   if (cn ~= 0 && cn ~= 1)
      num = num/cn;                    % normalize numerator
      den = den/cn;                    % normalize denominator
   end
   
         % poke num/den back to transfer function

   oo = poke(o,0,num,den);
   
   function [rnum,rden] = Roots(o,mode) % Get Roots of Transfer Function
      [num,den] = peek(o);
      
         % numerator roots
         
      if (all(num == 0)) 
         rnum = []; 
      else
         rnum = roots(num);
      end

         % denominator roots
      
      if ( mode == 1 )
         [ans,idx1] = sort(abs(rnum));
      else
         [ans,idx1] = sort(real(rnum));
      end
      rnum = rnum(idx1);               % re-order numerator roots

      %num = num(m-deg_num-1:m-1);

         % denominator roots

      if (all(den == 0))
         rden = []; 
      else
         rden = roots(den);
      end
      
         % sort denominator roots
         
      if ( mode == 1 ) 
         [~,idx2] = sort(abs(rden));
      else
         [~,idx2] = sort(real(rden));
      end
      rden = rden(idx2);               % re-order denominator roots
   end
end
function oo = CanTrf(o)                % Cancel Trf-Transfer Function  
   oo = o;                             % just in case
   caneps = opt(o,{'eps',1e-7});
   
      % calculate numerator and denominator roots
      
   [rnum,rden] = Roots(o,1);
   dirty = 0;		     % init dirty state

   degnum = length(rnum);
   degden = length(rden);
   
   if ( degden == 0  ||  degnum == 0 ) 
      oo = trim(o);
      return; 
   end

      % calculate relative distance matrix D: 
      %
      %    D := [D(i,j)] = [dr(i,j)/r(i,j)]
      %
      % with
      %
      %    dr(i,j) = abs(zero(j)-pole(i))
      %    r(i,j)  = abs(zero(j)+pole(i))

   D = [];
   for (i = 1:degden)
      r = abs((rnum + rden(i))/2);     % mean absolute value
      dr = abs(rnum - rden(i));        % absolute value of distance
      idx = find(r > eps);
      if ~isempty(idx)
         dr(idx) = dr(idx) ./ r(idx);
      end
      D = [D, dr];	 % distance matrix
   end

      % prepare cancellation

   idx_den = 1:degden;  idx_num = 1:degnum;

   for (j = 1:length(rden))
      
      delta = abs(D(:,j));
      found = find( delta < caneps );  
      
      for ( k = 1:length(found) )
	      i = found(k);
         
	      if ( idx_num(i) ~= 0  &  idx_den(j) ~= 0 )
            Cancel(o);                 % cancel pole/zero
            break;                     % can only cancel one pole/zero pair
	      end
      end
   end

      % if some cancellation happened then we have a dirty state
      % which has to be handeled ...
      
   [num,den] = peek(o);                % peek numerator/denominator
   if ( dirty ~= 0 )
      HandleDirty(o);
   end
   
      % normalize to denominator coefficien
      
   cn = den(1);
   if (cn ~= 0 && cn ~= 1)
      num = num/cn;                    % normalize numerator
      den = den/cn;                    % normalize denominator
   end
   
         % poke num/den back to transfer function

   oo = poke(o,num,den);
   oo = trim(oo);
   
   function HandleDirty(o)             % Handle Dirty Status           
      idx_num(find(idx_num == 0)) = [];
      idx_den(find(idx_den == 0)) = [];
      
         % K factor

      if ( all(num == 0)  &  all( den == 0 ) )
	      K = NaN;
      elseif ( all(num == 0) )
	      K = 0;
      elseif ( all(den == 0) )
	      K = inf;
      else
	      if ( degnum <= degden )
	         [ans1,ans2,K] = tf2zp(num,den);   % get gain K
         else
	         [ans1,ans2,K] = tf2zp(den,num);   % get gain K
	          K = 1/K;
         end
      end

         % new numerator and denominator

      [num,den] = Zp2Tf(o,rnum(idx_num),rden(idx_den),K);

      if ( length(num) == 0 ) num = 1; end	   % V1.0a
      if ( length(den) == 0 ) den = 1; end	   % V1.0a

         % new K factor (K1)

      if ( all(num == 0)  &  all( den == 0 ) )
	      K1 = NaN;
      elseif ( all(num == 0) )
	      K1 = 0;
      elseif ( all(den == 0) )
	      K1 = inf;
      else
	      if ( degnum <= degden )
	         [ans1,ans2,K1] = tf2zp(num,den);   % get gain K
         else
	         [ans1,ans2,K1] = tf2zp(den,num);   % get gain K
	         K1 = 1/K1;
	      end
      end
      
      num = K/K1*num;
   end
   function Cancel(o)                  % Cancel Pole/Zero              
      dirty = 1;
      idx_num(i) = 0;
      idx_den(j) = 0;

      if (control(o,{'verbose',1}) > 0)
         re = real(rnum(i));  im = imag(rnum(i));
         fprintf('cancel: %g',re);

         if ( abs(im) > eps )
            if ( im > 0)
               fprintf(' + i %g',im);
            else
               fprintf(' - i %g',-im);
            end
         end

         re = real(rden(j));  im = imag(rden(j));
         fprintf(' <--> %g',re);

         if ( abs(im) > eps )
            if ( im > 0)
               fprintf(' + i %g',im);
            else
               fprintf(' - i %g',-im);
            end
         end

         fprintf(' (delta: %g)\n',delta(i));
      end
   end
end

%==========================================================================
% Cancel Number
%==========================================================================

function oo = CanNumber(o)             % Cancel Ratio                  
   e = o.data.expo;
   x = o.data.num;
   y = o.data.den;
   cf = gcd(o,x,y);

   if ~isequal(cf,[1])
      [x,r] = div(o,x,cf);             % cancel common factor
      assert(isequal(r,[0]));

      [y,r] = div(o,y,cf);             % cancel common factor
      assert(isequal(r,[0]));
   end
   
   oo = poke(o,e,x,y);
end

%==========================================================================
% Cancel Polynomial
%==========================================================================

function oo = CanPoly(o)               % Cancel Polynomial             
   [num,den,expo] = peek(o);
   Num = [];  Den = [];
   
   for (i=1:length(expo))
      x = num(i,:);
      y = den(i,:);
      
      cf = gcd(o,x,y);

      if ~isequal(cf,[1])
         [x,r] = div(o,x,cf);          % cancel common factor
         assert(all(r==0));
         [y,r] = div(o,y,cf);          % cancel common factor
         assert(all(r==0));
      end
      [x,y,e] = trim(o,x,y,expo(i));     
      nx = length(x);  ny = length(y);
      idx = nx:-1:1;   idy = ny:-1:1;
      
      Xpo(i,1) = e;
      Num(i,idx) = x;
      Den(i,idy) = y;
   end
   
   Num = Num(:,size(Num,2):-1:1);                   % swap columns
   Den = Den(:,size(Den,2):-1:1);
   
   for (i=length(expo):-1:2)
      if all(Num(i,:)==0)
         Xpo(i)  = [];
         Num(i,:) = [];
         Den(i,:) = [];
      else
         break
      end
   end
   
   oo = poke(o,Xpo,Num,Den);
   oo.work.trim = true;
end

%==========================================================================
% Cancel Ratio
%==========================================================================

function oo = CanRatio(o)              % Cancel Ratio                  
   [x,y] = peek(o);

   if iszero(x)
      oo = corinth(o,'ratio');         % return zero ratio
      oo.work.can = true;
      oo.work.trim = true;
      return                           % bye!
   end

   if (order(y) > 0)
      cf = gcd(x,y);
      if ~iseye(cf) && ~iszero(cf) 
         if order(cf) > 0
            [x,r] = div(x,cf);            % cancel common factor
            assert(iszero(r));

            [y,r] = div(y,cf);            % cancel common factor
            assert(iszero(r));
         end
         
            % normalize to highest denominator coefficient = 1
            
         [x,y] = Normalize(o,x,y);
      end
   end

   if (order(y) == 0)
      oy = peek(y,0);                  
      for (j=0:order(x))
         oj = peek(x,j);
         oj = div(oj,oy);
         x = poke(x,oj,j);
      end
      
         % replace denominator by a number

      oy = number(o,1);
      y = poke(y,oy,0);
   end

   oo = poke(o,NaN,x,y);
   
   function [x,y] = Normalize(o,x,y)   % Normalize Rational Function 
      x = trim(touch(x));
      y = trim(touch(y));

         % pick n-th denominator coefficient 
         
      n = order(y);
      cn = peek(y,n);
      assert(~iszero(cn));

         % normalize denominator
         
      for (k=0:n-1)
         ck = peek(y,k);            % k-th demoniator coefficient
         ck = div(ck,cn);           % normaize k-th coeff
         y = poke(y,ck,k);          % poke back normalized
      end
      poke(y,number(o,1),n);        % poke a one to n-th denominator coeff

         % normalize numerator
         
      m = order(x);
      for (k=0:m)
         ck = peek(x,k);            % k-th demoniator coefficient
         ck = div(ck,cn);           % normaize k-th coeff
         x = poke(x,ck,k);          % poke back normalized
      end
   end
end

%==========================================================================
% Cancel Matrix
%==========================================================================

function o = CanMatrix(o)              % Cancel Matrix                  
   assert(type(o,{'matrix'}));

   M = o.data.matrix;
   [m,n] = size(M);

   for (i=1:m)
      for (j=1:n)
         oo = can(M{i,j});
         M{i,j} = oo;
      end
   end
   o.data.matrix = M;
end

%==========================================================================
% Helper
%==========================================================================

function D = Distance(o,rnum,rden)     % Distance Matrix               
%
% DISTANCE   calculate relative distance matrix D: 
%
%               D := [D(i,j)] = [dr(i,j)/r(i,j)]
%
%            with
%
%               dr(i,j) = abs(zero(j)-pole(i))
%               r(i,j)  = abs(zero(j)+pole(i))
%
   D = [];
   for (i = 1:length(rden))
      r = abs((rnum + rden(i))/2);     % mean absolute value
      dr = abs(rnum - rden(i));        % absolute value of distance
      idx = find(r > eps);
      if ~isempty(idx)
         dr(idx) = dr(idx) ./ r(idx);
      end
      D = [D, dr];	 % distance matrix
   end
end
function [rnum,rden] = Roots(o,mode)   % Get Transfer Function Roots   
   if type(o,{'szpk','zzpk','qzpk'})
      rnum = o.data.zeros;
      rden = o.data.poles;
      return
   end

   [num,den] = peek(o);

      % numerator roots

   if (all(num == 0)) 
      rnum = []; 
   else
      rnum = roots(num);
   end

      % denominator roots

   if ( mode == 1 )
      [ans,idx1] = sort(abs(rnum));
   else
      [ans,idx1] = sort(real(rnum));
   end
   rnum = rnum(idx1);                  % re-order numerator roots

   %num = num(m-deg_num-1:m-1);

      % denominator roots

   if (all(den == 0))
      rden = []; 
   else
      rden = roots(den);
   end

      % sort denominator roots

   if ( mode == 1 ) 
      [~,idx2] = sort(abs(rden));
   else
      [~,idx2] = sort(real(rden));
   end
   rden = rden(idx2);                  % re-order denominator roots
end
function [num,den] = Zp2Tf(o,z,p,K)    % Convert Zeros/Poles/K to TRF  
%
% ZP2TF	Zero-pole to transfer function conversion.
%	      
%           [num,den] = Zp2Tf(o,Z,P,K) % form transfer function to num/den
%
%        forms the transfer function:
%
%			           num(s)
%		      G(s) = -------- 
%			           den(s)
%
%	given a set of zero locations in vector Z, a set of pole locations
%	in vector P, and a gain in scalar K.  Vectors NUM and DEN are 
%	returned with numerator and denominator coefficients in descending
%	powers of s.  See TF2PZ to convert the other way.
%  
   T = data(o,'T');
   
   den = real(polynom(o,p(:)));
   [m,n] = size(z);
   
   num = vpa([]);
   for j=1:n
      zj = z(:,j);
      pj = real(polynom(o,zj)*K(j));
      num(j,:) = [zeros(1,1+m-length(pj),class(pj)) pj];
   end
   
   if isempty(num)
      num = K;
   end
   oo = trf(o,num,den,T);
end

