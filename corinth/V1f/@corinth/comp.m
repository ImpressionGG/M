function o = comp(o,x,y)               % Compare Two Rational Objects  
%
% COMP    Compare two rational objects
%
%            sgn = comp(o1,o2)
%            sgn = comp(o,x,y)         % compare two mantissa
%
%         Return value:
%
%            +1: for x > y
%             0: for x = y
%            -1: for x < y
%           inf: in case neither '<' nor '>' does apply
%
%         See also: RAT, TRIM, SUB
%
   if (nargin == 2)                    % compare objects
      o1 = o;  o2 = x;                 % rename input args
      if ~isequal(o1.type,o2.type)
         o = inf;
         return                        % not matching
      end
      
      switch o1.type
         case 'number'
            o = CompNumber(o,o1,o2);
         case 'poly'
            o = CompPoly(o,o1,o2);
         otherwise
            error('implementation restriction!');
      end
   elseif (nargin == 3)
      o = Comp(o,x,y);
   end
end

%==========================================================================
% Compare Two Mantissa
%==========================================================================

function sgn = Comp(o,x,y)             % Compare Mantissas             
   if all(x>=0) && any(y<0)
      sgn = +1;
   elseif any(x<0) && all(y>=0)
      sgn = -1;
   elseif any(x<0) && any(y<0)
      sgn = Comp(o,-y,-x);
   else
      [x,y] = form(o,x,y,0);
      sgn = sign(x-y);
      idx = [find(sgn~=0), 1];         % make sure that idx is not empty!
      sgn = sgn(idx(1));
   end
end

%==========================================================================
% Compare Two Numbers
%==========================================================================

function sgn = CompNumber(o,o1,o2)     % Compare Polynomials             
   od = sub(o1,o2);                    % difference
   
   [num,den,xpo] = peek(od);
   sgn = prod(sign(num)) / prod(sign(den));
end

%==========================================================================
% Compare Two Polynomials
%==========================================================================

function sgn = CompPoly(o,o1,o2)         % Compare Polynomials             
   od = sub(o1,o2);                      % difference
   
   [num,den,xpo] = peek(od);
   if all(all(num==0))
      sgn = 0;
   else
      sgn = inf;
   end
end

