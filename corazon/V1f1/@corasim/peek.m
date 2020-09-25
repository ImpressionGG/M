function [num,den,T] = peek(o,i,j)     % Peek Numerator/Denominator    
%
% PEEK   Peek numerator and denominator from a corasim system
%
%           oo = system(corasim,A,B,C,D);
%           [num,den,T] = peek(oo,i,j) % peek numerator & denominator
%           [num,den,T] = peek(oo)     % i = 1, j = 1
%           
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORASIM, SYSTEM
%
   switch o.type
      case {'css','dss'}
         [A,B,C,D,T] = system(o);
         if (nargin < 2)
            i = 1;
         end
         if (nargin < 3)
            j = 1;
         end
         
         if (i < 0 || i > size(C,1))
            error('i (arg2) exceeds number of outputs');
         end
         if (j < 0 || j > size(B,2))
            error('j (arg3) exceeds number of inputs');
         end
         
         [num,den] = Ss2tf(o,A,B(:,j),C(i,:),D(i,j));
      case {'strf','ztrf'}
         [num,den] = data(o,'num,den');
   end
end

%==========================================================================
% Convert State Space Representation to transfer Function
%==========================================================================

function [num, den] = Ss2tf(o,varargin) % State Space to Transfer Fct. 
%
% SS2TF  State-space to transfer function conversion.
%        [num,den] = Ss2tf(A,B,C,D,iu) calculates the transfer function:
%
%                    num(s)          -1
%            G(s) = -------- = C(sI-A) B + D
%                    den(s)
%
%        of the system:
%           .
%           x = Ax + Bu
%           y = Cx + Du
%
%        from the iu'th input.  Vector den contains the coefficients of the
%        denominator in descending powers of s.  The numerator coefficients
%        are returned in matrix num with as many rows as there are 
%        outputs y.
%
   try                                 % compute poles and zeros
      [z,p,k] = Ss2zp(o,varargin{:});
   catch me
      throw(me)
   end

      % build denominator
      
   den = poly(p);

      % build numerator(s)
      
   [ny,nu] = size(k);
   if nu==0                            % legacy
      num = zeros(ny,0);
   else
      lden = numel(den);
      num = zeros(ny,lden);
      for j=1:ny
         zj = z(:,j);
         zj = zj(isfinite(zj));
         num(j,lden-numel(zj):lden) = k(j) * poly(zj);
      end
   end
   
   num = Trim(o,num);
   den = Trim(o,den);
end

%==========================================================================
% Convert State Space Representation to Zero/Pole Representation
%==========================================================================

function [z,p,k] = Ss2zp(o,a,b,c,d,iu) % State Space to Zero/Pole      
%
%   SS2ZP	State-space to zero-pole conversion.
%
%	            [z,p,k] = SS2ZP(A,B,C,D,iu)  factored transfer function
%
%           calculates the transfer function in factored form
%
%			                   -1           (s-z1)(s-z2)...(s-zn)
%		         G(s) = C(sI-A) B + D =  k ---------------------
%			                                (s-p1)(s-p2)...(s-pn)
%	         of the system:
%		         .
%		         x = Ax + Bu
%		         y = Cx + Du
%
%	         from the iu'th input.  Vector p contains the pole locations of 
%           the denominator of the transfer function.  The numerator zeros
%           are returned in the columns of matrix z with as many columns as
%           there are outputs y. The gains for each numerator transfer 
%           function are returned in column vector k.
%
   o.argcheck(5,5,nargin);
   o.abcdcheck(a,b,c,d);

   if (nargin < 6)
      iu = 1:size(b,2);
   end
   
      % remove relevant input
      
   b = b(:,iu);
   d = d(:,iu);

      % do poles first, they're easy
      
   p = eig(a);

      % now try zeros, they're harder
      
   [no,ns] = size(c);
   z = zeros(ns,no) + inf;		         % set whole Z matrix to infinities
   
      % loop through outputs, finding zeros
      
   for i=1:no
      s1 = [a b;c(i,:) d(i)];
      s2 = diag([ones(1,ns) 0]);
      zv = eig(s1,s2);
      
         % now put NS valid zeros into Z. There will always be at least one
         % NaN or infinity
         
      zv = zv((zv ~= nan)&(zv ~= inf));
      if length(zv) ~= 0
         z(1:length(zv),i) = zv;
      end
   end

      % now finish up by finding gains using Markov parameters
      
   k = d;  CAn = c;
   while any(k==0)	                  % do until all k's are finished
      markov = CAn*b;
      i = find(k==0);
      k(i) = markov(i);
      CAn = CAn*a;
   end
end

%==========================================================================
% Helper
%==========================================================================

function y = Trim(o,x)                 % Trim Mantissa                 
%
% TRIM    Trim mantissa: remove leading mantissa zeros
%
   idx = find(x~=0);
   if isempty(idx)
      y = 0;
   else
      y = x(idx(1):end);
   end
end
