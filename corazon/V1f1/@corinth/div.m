function [q,r] = div(o,x,y)            % Divide Two Rational Objects
%
% DIV   Divide two rational objects
%
%       1) Dividing Mantissa
%
%          o = base(rat,100);
%          [q,r] = div(o,[41 32 76 78],[58 67])  % divide two mantissa
%
%       2) Dividing Objects
%
%          oo = div(o1,o2)
%
%       Example 1:
%
%          o = base(corinth,10);
%          [q,r] = mul(o,[7 3 8 5],[8 9])        % divide two mantissa
%
%          => q = [8 2], r = [8 7] 
%
%       Example 2:
%
%          o = base(corinth,100);
%          [q,r] = div(o,[41 32 76 78],[58 67])  % divide two mantissa
%
%          => q = [70 44], r = [5 30] 
%
%       Example 3: polynomial division
%
%          o = base(corinth,100);
%          p1 = poly(o,[6 8]           % 6 s + 8
%          p2 = poly(o,[7 8 9])        % 7 s^2 + 8 s + 9
%          p = mul(p1,p2)              % 42 s^3 + 104 s^2 + 118 s + 72
%
%       See also: RAT, TRIM, FORM, COMP, ADD, SUB, MUL, DIV
%
   o = touch(o);                       % just in case of a copy somewhere

   if (nargin == 3)
      o.profiler('mantdiv',1);
      [q,r] = Div(o,x,y);
      o.profiler('mantdiv',0);
   else
      x = touch(x);
      switch o.type
         case 'number'
            o.profiler('numbdiv',1);
            [q,r] = DivNumber(o,x);
            o.profiler('numbdiv',0);
            
         case 'poly'
            o.profiler('polydiv',1);
            [q,r] = DivPoly(o,x);
            o.profiler('polydiv',0);
            
         case 'ratio'
            o.profiler('ratiodiv',1);
            if (nargout > 1)
               [q,r] = DivRatio(o,x);
            else
               q = DivRatio(o,x);
            end
            o.profiler('ratiodiv',0);
            
         otherwise
            error('implermentation restriction!');
      end

      q = can(q);  
      q = trim(q);

      if (nargout > 1)
         r = can(r);
         r = trim(r);
      end
   end
end

%==========================================================================
% Divide Two Mantissa
%==========================================================================

function [q,r] = Div(o,x,y)            % Mantissa Division             
   global CorinthVerbose
   if isempty(CorinthVerbose)
      CorinthVerbose = 0;
   end
   
   sgnx = 1;
   if any(x< 0)
      x = -x;  sgnx = -sgnx;
   end
   
   sgny = 1;
   if any(y<0)
      y = -y;  sgny = -sgny;
   end
   
      % x and y must be trimmed!
      
   if (x(1) == 0)
      x = trim(o,x);
   end
   if (y(1) == 0)
      y = trim(o,y);
   end
   
      % init base and head, and calculate number of digits
      
   base = o.data.base;
   nx = length(x);
   ny = length(y);
   
      % the main loop iterates over i=1:nx headers hi, while the numerator
      % x gets i transformations xi (x1 extends x by ny leading zeros)
      
   xi = [zeros(1,ny),x];  q = [];
   for (i=1:nx)
      hi = xi(i:i+ny);
      [qi,ri] = Division(o,hi,y,CorinthVerbose);
      q = [q qi];
      xi(i:i+ny) = ri;
   end
   
      % final assertion: if recent replacement of xi by remainder ri
      % is set to zero then whole xi must be zero!
      
   xi(i:i+ny) = 0*ri;
   if ~all(xi==0)
      'stop';
   end
   
   if ~all(xi==0)
      assert(all(xi==0));              % this way to allow break point set
   end
   
      % trim results and set sign correctly
      
   if (q(1) == 0)
      q = trim(o,q);
   end
   q = q * sgnx * sgny;
   
   r = ri;
   if (r(1) == 0)
      r = trim(o,r);
   end
   r = r * sgnx;
end
function [q,r] = Division(o,x,y,verbose)    % Division Helper          
%
% DIVISION   Integer division for specific boundary conditions, where
%            y is non-empty and x has one more digit than y and both x and
%            y are non-negative.
%
%               [q,r] = Division(o,x,y)
%
%            The quotient of this kind of division is one single digit,
%            i.e. q < base!
%   
   nx = length(x);  ny = length(y);
   if ~(ny > 0 && nx==ny+1 && all(x>=0) && all(y>=0))
      assert(ny > 0 && nx==ny+1 && all(x>=0) && all(y>=0));
   end

   base = o.data.base;
   h = x(1)*base + x(2);
   
      % trivial check whether division x/y can be greater than zero
      
   if (h < y(1))       
      q = 0;
      r = x;
      return                           % note q = 0 < base!
   end
   
      % so we know that q > 0! next calculate the most likely quotient
      % q = floor(h/y(1)). It will work out, e.g., when y(2:end) is
      % zero (or empty)

   corazon.profiler('Division',1);     % start profiling from here
   
      % now we need a most likely guess for the quotient. Note that
      % since ny > 0 and nx == ny+1 (see assertion) we conclude ny >= 1
      % and nx >= 2, on which we can base an estimate. Hovever a better
      % estimate can be calculated if ny >= 2 and nx >= 3, with which we
      % try to go. The most likely quotient will work out, e.g., when 
      % y(2:end) is zero (or empty)
      
   if (ny >= 2)                        % which means nx >= 3 due to assert
      hh = h*base + x(3);
      yy = y(1)*base + y(2);
      q = floor(hh/yy);                % strong most likely quotient
   else
      q = floor(h/y(1));               % weaker most likely quotient
   end
   
      % note that if y(2:end) is non zero then q*y could be greater than x!
      % in such cases we have to reduce q until q*y <= x fits
   
   p = Mul(o,q,y);
   a = 0.2;                            % some stupid decay factor
   guess = 0;                          % init guess iterations
   
      % in some seldom cases q could be too small, so we make a trial
      % whether we are faced with such case ...
      
   if (comp(o,p,x) <= 0)
      pp = add(o,p,y);
      if (comp(o,pp,x) <= 0)
         p = pp;
         q = q+1;
      end
   end
  
      % now p should be well suited for the next steps
   
   while (comp(o,p,x) > 0)             % while q*y > x
      guess = guess + 1;               % count guess iterations
      
         % now decrement estimated quotient and see where we are
         
      q = q-1;                         % decrement quotien
      p = Mul(o,q,y);
      
         % in addition try a much bigger decay by reducing q by the
         % factor (1-a), i.e. qq = (1-a)*q. 
         
      qq = floor((1-a)*q);             % do some stupid decay
      pp = Mul(o,qq,y);

         % if this works out well we can take over q = qq, otherwise the
         % decay factor a was too big and we reduce a = a/2 to be better
         % prepared next time
      
      if (comp(o,pp,x) > 0)            % does this decay work out?
         q = qq;                       % ohh, yes => lucky! - take over
      else
         a = a/2;                      % ohh, no => next time less decay
      end
   end
      
   if (verbose >= 3)
      Trace(o,guess);                  % trace guess efficiency
   end
   
      % now we have q*y < = x and we can calculate the remainder
      
   r = sub(o,x,p);
   r = [zeros(1,nx-length(r)),r];      % let's have nx digits for r
   
      % final assertion: quotient q must be a digit
      
   if (q >= o.data.base)               % assertion violated ?
      assert(q < o.data.base);
   end
   
      % final check: r must be less than divisor y
      
   ok = (comp(o,r,y) < 0);
   if ~ok
      assert(ok);
   end
   
   corazon.profiler('Division',0);
end
function [q,r] = Old1Division(o,x,y)   % Old Division Helper           
%
% DIVISION   Integer division for specific boundary conditions, where
%            y is non-empty and x has one more digit than y and both x and
%            y are non-negative.
%
%               [q,r] = Division(o,x,y)
%
%            The quotient of this kind of division is one single digit,
%            i.e. q < base!
%   
   nx = length(x);  ny = length(y);
   if ~(ny > 0 && nx==ny+1 && all(x>=0) && all(y>=0))
      assert(ny > 0 && nx==ny+1 && all(x>=0) && all(y>=0));
   end

   h = x(1)*o.data.base + x(2);
   
      % trivial check whether division x/y can be greater than zero
      
   if (h < y(1))       
      q = 0;
      r = x;
      return                           % note q = 0 < base!
   end
   
      % so we know that q > 0! next calculate the most likely quotient
      % q = floor(h/y(1)). It will work out, e.g., when y(2:end) is
      % zero (or empty)

   corazon.profiler('Division',1);     % start profiling from here
   
   q = floor(h/y(1));                  % most likely quotient

      % but if y(2:end) is non zero then q*y could be greater than x!
      % in such cases we have to reduce q until q*y <= x fits
   
   p = Mul(o,q,y);
   a = 0.2;
   guess = 0;                          % init guess iterations
   while (comp(o,p,x) > 0)             % while q*y > x
      guess = guess + 1;               % count guess iterations
      q = q-1;
      p = Mul(o,q,y);
      
      qq = floor((1-a)*q);
      pp = Mul(o,qq,y);
      if (comp(o,pp,x) > 0)
         q = qq;
      else
         a = a/2;
      end
   end
   
   if (guess>0)
      %fprintf('   ### %g divsion guesses\n',guess);
   end

      % now we have q*y < = x and we can calculate the remainder
      
   r = sub(o,x,p);
   r = [zeros(1,nx-length(r)),r];      % let's have nx digits for r
   
      % final assertion: quotient q must be a digit
      
   if (q >= o.data.base)               % assertion violated ?
      assert(q < o.data.base);
   end
   
   corazon.profiler('Division',0);
end
function [q,r] = Old2Division(o,x,y)   % Old Division Helper           
%
% DIVISION   Integer division for specific boundary conditions, where
%            y is non-empty and x has one more digit than y and both x and
%            y are non-negative.
%
%               [q,r] = Division(o,x,y)
%
%            The quotient of this kind of division is one single digit,
%            i.e. q < base!
%   
   nx = length(x);  ny = length(y);
   if ~(ny > 0 && nx==ny+1 && all(x>=0) && all(y>=0))
      assert(ny > 0 && nx==ny+1 && all(x>=0) && all(y>=0));
   end

   base = o.data.base;
   h = x(1)*base + x(2);
   
      % trivial check whether division x/y can be greater than zero
      
   if (h < y(1))       
      q = 0;
      r = x;
      return                           % note q = 0 < base!
   end
   
      % so we know that q > 0! next calculate the most likely quotient
      % q = floor(h/y(1)). It will work out, e.g., when y(2:end) is
      % zero (or empty)

   corazon.profiler('Division',1);     % start profiling from here
   
   q = floor(h/y(1));                  % most likely quotient

   if (nx >= 4)
      h2 = ((x(1)*base + x(2))*base + x(3))*base + x(4);
      y2 = (y(1)*base + y(2))*base + y(3);
      q2 = floor(h2/y2);
      p2 = Mul(o,q2,y);
      c2 = comp(o,p2,x);
   end
   if (nx >= 3)
      h1 = (x(1)*base + x(2))*base + x(3);
      y1 = (y(1)*base + y(2));
      q1 = floor(h1/y1);
      p1 = Mul(o,q1,y);
      c1 = comp(o,p1,x);
q = q1;
   end
   
      % but if y(2:end) is non zero then q*y could be greater than x!
      % in such cases we have to reduce q until q*y <= x fits
   
   p = Mul(o,q,y);
   a = 0.2;
   guess = 0;                          % init guess iterations
   while (comp(o,p,x) > 0)             % while q*y > x
      guess = guess + 1;               % count guess iterations
      q = q-1;
      p = Mul(o,q,y);
      
      qq = floor((1-a)*q);
      pp = Mul(o,qq,y);
      if (comp(o,pp,x) > 0)
         q = qq;
      else
         a = a/2;
      end
   end
   
      % debug efficiency
      
   Trace(o,guess);                     % do some debug tracing
   
      % now we have q*y < = x and we can calculate the remainder
      
   r = sub(o,x,p);
   r = [zeros(1,nx-length(r)),r];      % let's have nx digits for r
   
      % final assertion: quotient q must be a digit
      
   if (q >= o.data.base)               % assertion violated ?
      assert(q < o.data.base);
   end
   
   corazon.profiler('Division',0);
end

%==========================================================================
% Divide Two Numbers
%==========================================================================

function [oo,rr] = DivNumber(o1,o2)     % Division of two Numbers      
   if (o1.data.base ~= o2.data.base)
      error('incompatible bases!');
   end
   
   oo = o1;
   oo.data.expo = o1.data.expo - o2.data.expo;
   
   num = mul(o1,o1.data.num,o2.data.den);
   den = mul(o1,o1.data.den,o2.data.num);

   [num,den] = can(oo,num,den);        % cancel by common factor cf

   oo.data.num = num;
   oo.data.den = den;

   rr = corinth(oo,'number');
end

%==========================================================================
% Divide Two Polynomials
%==========================================================================

function [q,r] = DivPoly(ox,oy)        % Divide Two Polynomials        
%
% DIVPOLY  Polynomial division
%
%          Example: ox = 2s^2 + 3s + 5, oy = 5s + 3
%
%             (2s^2 + 3s   + 5) : (5s + 3) = 2/5s + 9/25 + (98/25):(5s + 3)
%             -2s^2 - 6/5s - 0
%             ----------------
%              0s^2 +9/5s  + 5
%                   -9/5s  - 27/25
%                   --------------
%                      0s  + 98/25
%
   if (ox.data.base ~= oy.data.base)
      error('incompatible bases!');
   end
   assert(isequal(ox.type,'poly') && isequal(oy.type,'poly'));
   
   ox = can(ox);
   oy = can(oy);
   
   ox = trim(ox);
   oy = trim(oy);
   
   
   nx = order(ox);  ny = order(oy);  
   
   q = corinth(ox,'poly');             % quotient
   r = ox;                             % initial remainder
   
   if (nx < ny)
      return                           % for nx < ny we are done!
   end
   
   cy = peek(oy,ny);
   for (i=1:nx-ny+1)
      k = nx-i+1;                      % indexes highest (non zero) r-power

      cx = peek(r,k);
      c = div(cx,cy);
      
      kq = k-ny;
      q = poke(q,c,kq);
      
         % calculate product pr = cq * oy
         
      p = corinth(ox,'poly');          % init product p = c*oy
      for (j=0:ny)
         oyj = peek(oy,j);
         prj = c*oyj;
         
         kp = kq + j;
         p = poke(p,prj,kp);
      end
      
         % now subtract product p from r
         
      r = sub(r,p);
   end
end

%==========================================================================
% Divide Two Rationals
%==========================================================================

function [q,r] = DivRatio(ox,oy)       % Divide Two Polynomials        
%
% DIVRATIO  Division of two rational functions
%
%              o1 = ratio(o,[1 2]);
%              o2 = ratio(o,[5 6 7]);
%              oo = div(o1,o2)
%
   if (ox.data.base ~= oy.data.base)
      error('incompatible bases!');
   end
   assert(isequal(ox.type,'ratio') && isequal(oy.type,'ratio'));

   [numx,denx,~] = peek(ox);           % numerator & denominator polynomial
   [numy,deny,~] = peek(oy);           % numerator & denominator polynomial

   num = mul(numx,deny);
   den = mul(denx,numy);

   q = poke(ox,NaN,num,den);

      % cancel and trim

   q.work.can = false;
   q.work.trim = false;

   q = can(q);
   q = trim(q);

   if (nargout > 1)
      r = corinth(q,'ratio');          % zero rational
   end
end

%==========================================================================
% Helpers
%==========================================================================

function z = Mul(o,x,y)                % Multiply Mantissa             
%
% MUL    Multiply two mantissa; this is exactly the same function as 
%        the local work horse of the call z=mul(o,x,y). Code has been 
%        duplicated for profiling analysis reasons
%
   if (x(1) == 0)
      x = trim(o,x);
   end
   if (y(1) == 0)
      y = trim(o,y);
   end

   sign = 1;
   if any(x< 0)
      x = -x;  sign = -sign;
   end
   if any(y<0)
      y = -y;  sign = -sign;
   end
   
   base = o.data.base;
   
   n = length(x);
   z = 0*x;                              % init z
   for (i=1:length(y))
      z = [z 0];                         % shift intermediate result
      t = 0*z;                           % temporary result
      k = length(z);
      
      yi = y(i);  
      carry = 0;
      for (j=1:length(x))
         xj = x(n+1-j); 
         prod = xj * yi + carry;
         
         carry = floor(prod/base);
         remain = prod - carry*base;
         
         t(k) = t(k) + remain;
         k = k-1;
      end
      
      if (k > 0)
         t(k) = carry;
      elseif (carry ~= 0)
         t = [carry t];                % assert(carry == 0);
      end
      z = add(o,z,t);
   end
   z = sign*z;
end
function Trace(o,guess)                % Excess Division Tracing       
   persistent count guesses
   
   if isempty(count)
      count = 0;  guesses = 0;
   end
   
   count = count + 1;  
   guesses = guesses + 1+guess;
   
   if (rem(count,2000)==0 || guess >= 2)
      excess = o.rd((guesses/count-1)*100,2);   % excess guess ratio [%]
      fprintf('   ### %g excess division guesses (%g%%)\n',guess,excess);
   end
end
