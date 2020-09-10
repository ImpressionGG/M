function o = gcd(o,x,y)                % Greatest Common Divisor       
%
% GCD   Greatest common divisor (GCD) of two rational objects
%
%       1) GCD of two Mantissa
%
%          o = base(rat,100);
%          [cf,x,y] = gcd(o,[10 71],[4 62])   % GCD of two mantissa
%
%       2) GCD of two Objects: oo receives GCD, o1 and o2 are both
%          canceled by GCD
%
%          oo = gcd(o1,o2)             % calc GCD of o1 and o2
%
%       Example:
%
%          o = base(rat,10);
%          cf = gcd(o,[10 71],[4 62])   % divide two mantissa
%
%          => cf = [21] (gcd)
%
%       See also: CORINTH, TRIM, FORM, CAN
%
   if (nargin == 3)
      o = Gcd(o,x,y);
   else
      o1 = o;  o2 = x;                 % rename args
      [o1,o2] = cast(o1,o2);           % cast to same type 
      
      switch o1.type
         case 'poly'
            o = GcdPoly(o1,o2);
         otherwise
            error('implementation');
      end
   end
end

%==========================================================================
% GCD of Two Mantissa
%==========================================================================

function cf = Gcd(o,x,y)               % GCD of two Mantissa           
   if any(x< 0)
      x = -x;
   end
   if any(y<0)
      y = -y;
   end
  
      % x and y must be trimmed!
      
   x = trim(o,x);
   y = trim(o,y);
   
   if (comp(o,x,y) >= 0)
      a = x;  b = y;
   else
      a = y;  b = x;
   end
   
      % GCD loop
      
   while (1)
      if all(b==0)
         break;
      end
      
      [q,r] = div(o,a,b);
      a = b;  b = r;
   end
   cf = a;                             % resulting common factor
end

%==========================================================================
% GCD of Two Objects
%==========================================================================

function oo = GcdPoly(o1,o2)         % GCD of polynomials        
   assert(isequal(o1.type,'poly') && isequal(o2.type,'poly'));
   talk = (opt(o1,{'verbose',0}) >= 2);

   n1 = order(o1);  n2 = order(o2);
   if (n1 == 0 || n2 == 0)
      oo = poly(o1,[1]);               % GCD = 1 !
      return
   end

   if (n1 >= n2)
      a = o1;  b = o2;
   else
      a = o2;  b = o1;
   end
   
      % GCD loop
      
   while (1)
      if iszero(b)
         break;
      end
      
      n1 = order(a);  n2 = order(b);
      if (n1 < n2)
         assert(0);                    % should never be!
         oo = poly(o1,[1]);            % GCD = 1 !
         return                        % bye!
      end
      
      if (talk)
         fprintf('      GcdPoly: [q,r] = div(a(%g#%g),b(%g#%g))\n',...
                        order(a),digits(a), order(b),digits(b)); 
      end

      [q,r] = div(a,b);
      a = b;  b = r;
   end
   oo = a;                             % resulting common factor
end
