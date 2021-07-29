function [z,p,k] = ss2zp(o,a,b,c,d,iu) % State Space to Zero/Pole      
%
%   SS2ZP	State-space to zero-pole conversion.
%
%	            [z,p,k] = SS2ZP(o,A,B,C,D,iu)  factored transfer function
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
%           Copyright(c): Bluenetics 2020
%
%           See also: CORASIM, TRF, SYSTEM, ZP2TF
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
         
%     zv = zv((zv ~= nan)&(zv ~= inf));
      zv = zv((~isnan(zv)) & (~isinf(zv)));
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
