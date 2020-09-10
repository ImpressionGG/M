function [T,S] = tffloop(L1,L2,L3,L4,L5,L6,L7,L8,L9)
%
% TFFLOOP Closed LOOP transferfunction. 
%
%            [T,S] = tffloop(L)
%
%         Calculates the closed loop transfer function T = L / (1 + L)
%         and the sensitivity function S = 1 / (1 + L).
%
%	  If more than one input arguments are applied, the open loop
%	  transfer function is assumed to be the product of the input
%         arguments.
%
%         Example:
%
%	     [T,S] = tffloop(L1,L2,L3)
%
%         is exactly the same as
%
%            [T,S] = tffloop(tffmul(L1,L2,L3))
%
%      See also: tffnew, tffcan, tfftrim, tffadd, tffsub, tffmul, tffdiv
%

   if ( nargin == 0 )
      error('Missing arguments');
   elseif ( nargin == 1 )
      L = L1; 
   elseif ( nargin == 2 )
      L = tffmul(L1,L2);
   elseif ( nargin == 3 )
      L = tffmul(L1,L2,L3);
   elseif ( nargin == 4 )
      L = tffmul(L1,L2,L3,L4);
   elseif ( nargin == 5 )
      L = tffmul(L1,L2,L3,L4,L5);
   elseif ( nargin == 6 )
      L = tffmul(L1,L2,L3,L4,L5,L6);
   elseif ( nargin == 7 )
      L = tffmul(L1,L2,L3,L4,L5,L6,L7);
   elseif ( nargin == 8 )
      L = tffmul(L1,L2,L3,L4,L5,L6,L7,L8);
   elseif ( nargin == 9 )
      L = tffmul(L1,L2,L3,L4,L5,L6,L7,L8,L9);
   end

   L = tfftrim(L);
   l = max(size(L));	       % degree + 2

   num = L(1,2:l);  den = L(2,2:l);
   T = tffnew(num, num + den);  T(:,1) = L(:,1);

   if ( nargout >= 2 )
      S = tffnew(den, num + den);  S(:,1) = L(:,1);
   end;
end
