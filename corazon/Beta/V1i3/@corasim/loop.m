function [T,S] = loop(F,K)
%
% LOOP   Closed Loop transfer function T(s) and sensitivity function S(s)
%        based on open loop transfer function L(s) or forward transfer
%        function F(s) and backward transfer function K(s).
%
%           [T,S] = loop(F,K)
%
%                               +----------+
%                           e   |          |
%                r  ---->o----->|   F(s)   |------*----> y
%                        ^ -    |          |      |
%                        |      +----------+      |
%                        |                        |
%                        |      +----------+      |
%                        |      |          |      |
%                        +------|   K(s)   |<-----+
%                               |          |
%                               +----------+
%
%        Total transfer function: T(s) = F(s)/(I + K(s)*F(s)) = F(s)*S(s)
%        Sensitivity function:    S(s) = I/(I + K(s)*F(s))
%
%                            +---------------+
%                            |     F(s)      |
%                r  -------->| ------------- |--------->  y
%                            | 1 + F(s)*K(s) |
%                            +---------------+
%        Theory:
%           
%           y = F*e,  
%           e = r - K*y = r - K*F*e  =>  (I + K*F)*e = r
%           
%           e = 1/(1 + F*K)*r  =>  e = S*r   with  S := 1/(1 + F*K)
%           y = F/(1 + F*K)*r  =>  y = T*r   with  T := F/(1 + F*K)
%
%        For a state space representation of F(s) and feedback matrix K
%
%           x`= A*x + B*e              => x`=A*x + B*r - B*K*y
%           y = C*x + D*e
%           e = r - K*y
%
%        we get:
%
%           y = C*x + D*(r-Ky) = C*x + D*r - D*K*y => (I+D*K)*y = C*x + D*r
%
%        Let M := inv(I+D*K) => y = M*C*x + M*D*r 
%
%           x`= (A-B*K*M*C)*x + (B-B*K*M*D)*r
%           y = M*C*x + M*D*r
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORASIM, STEP, BODE, RLOC
%
   if (nargin < 2)
      B = 1;
   end
   
   if type(F,{'css','dss'})
      if (nargout >= 2)
         error('implementation restriction');
      end
      T = LoopSs(F,K);
   else
      if type(F,{'matrix'})
         [m,n] = size(F);
         I = eye(n);
      else
         I = 1;
      end

      S = inv(I+K*F);
      T = F*S;
   end
end

function [T,S] = LoopSs(oo,K)
%
%  x` = A*x + B*e
%  y  = C*x + D*e
%  e  = r - K*y
%
%  => y = C*x + D*r - D*K*y
%
%  a) D = 0:
%  =========
%
%     y = C*x
%     x`= A*x + B*(r-K*y) = A*x + B*r - B*K*C*x = (A-B*K*C)*x + B*r
%
%     x`= (A-B*K*C)*x + B*r
%     y = C*x
%
%  a) D ~= 0:
%  ==========
%
%     y = C*x + D*(r-K*y) = C*x + D*r - D*K*y
%     (I+D*K)*y = C*x + D*r  =>  y = inv(I+D*K)*C*x + inv(I+D*K)*D*r
%
%     Let M := inv(I+D*K) => y = M*C*x + M*D*r
%
%     x`= A*x + B*(r-K*y) = A*x + B*r - B*K*y 
%     x`= A*x + B*r - B*K*M*C*x - B*K*M*D*r
%
%     x'= (A-B*K*M*C)*x + (B-B*K*M*D)*r
%     y = M*C*x + M*D*r
%
   assert(type(oo,{'css','dss'}));
   [A,B,C,D] = system(oo);
   
   if isa(K,'double')
      if all(all(D == 0))
         AT = A - B*K*C;
         BT = B;
         CT = C;
         DT = D;
      elseif (det(D) ~= 0)
         I = eye(size(D));
         M = inv(I+D*K);
         AT = A - B*K*M*C;
         BT = B - B*K*M*D;
         CT = M*C;
         DT = M*D;
      else
         error('no solution');
      end
      
      T = system(oo,AT,BT,CT,DT);
   else
      error('implementation restriction');
   end
end
