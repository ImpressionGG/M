function [o,r] = div(o,x,y)            % Divide Two Rational Objects
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
%          o = base(rat,10);
%          [q,r] = mul(o,[7 3 8 5],[8 9])        % divide two mantissa
%
%          => q = [8 2], r = [8 7] 
%
%       Example 2:
%
%          o = base(rat,100);
%          [q,r] = div(o,[41 32 76 78],[58 67])  % divide two mantissa
%
%          => q = [70 44], r = [5 30] 
%
%       See also: RAT, TRIM, FORM, COMP, ADD, SUB, MUL, DIV
%
   if (nargin == 3)
      [o,r] = Div(o,x,y);
   else
      switch o.type
         case 'number'
            [o,r] = DivRatio(o,x);
         case 'poly'
            [o,r] = DivPoly(o,x);
         otherwise
            error('implermentation restriction!');
      end
   end
end

%==========================================================================
% Divide Two Mantissa
%==========================================================================

function [q,r] = Div(o,x,y)            % Mantissa Division             
   sgnx = 1;
   if any(x< 0)
      x = -x;  sgnx = -sgnx;
   end
   
   sgny = 1;
   if any(y<0)
      y = -y;  sgny = -sgny;
   end
   
      % x and y must be trimmed!
      
   x = trim(o,x);
   y = trim(o,y);
   
      % init base and head, and calculate number of digits
      
   base = o.data.base;
   nx = length(x);
   ny = length(y);
   
      % the main loop iterates over i=1:nx headers hi, while the numerator
      % x gets i transformations xi (x1 extends x by ny leading zeros)
      
   xi = [zeros(1,ny),x];  q = [];
   for (i=1:nx)
      hi = xi(i:i+ny);
      [qi,ri] = Division(o,hi,y);
      q = [q qi];
      xi(i:i+ny) = ri;
   end
   
      % final assertion: if recent replacement of xi by remainder ri
      % is set to zero then whole xi must be zero!
      
   xi(i:i+ny) = 0*ri;
   if ~all(xi==0)
      'stop';
   end
   assert(all(xi==0));
   
      % trim results and set sign correctly
      
   q = trim(o,q) * sgnx * sgny;
   r = trim(o,ri) * sgnx;
end
function [q,r] = Division(o,x,y)       % Division Helper               
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
      'stop';
   end
   assert(ny > 0 && nx==ny+1 && all(x>=0) && all(y>=0));
   
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
      
   q = floor(h/y(1));                  % most likely quotient

      % but if y(2:end) is non zero then q*y could be greater than x!
      % in such cases we have to reduce q until q*y <= x fits
   
   p = mul(o,q,y);
   a = 0.2;
   while (comp(o,p,x) > 0)             % while q*y > x
      q = q-1;
      p = mul(o,q,y);
      
      qq = floor((1-a)*q);
      pp = mul(o,qq,y);
      if (comp(o,pp,x) > 0)
         q = qq;
      else
         a = a/2;
      end
   end

      % now we have q*y < = x and we can calculate the remainder
      
   r = sub(o,x,p);
   r = [zeros(1,nx-length(r)),r];      % let's have nx digits for r
   
      % final assertion: quotient q must be a digit
      
   if ~(q < o.data.base)
      'stop';
   end
   assert(q < o.data.base);
end

%==========================================================================
% Divide Two Ratios
%==========================================================================

function [oo,rr] = DivRatio(o1,o2)     % Division of two Ratios        
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
