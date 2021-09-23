function [K,P]=dlqr(o,A,B,Q,R)         % Linear Quadratic Regulator    
%
% DLQR   Linear quadratic regulator design for discrete-time systems.
%
%	         [K,P] = Dlqr(A,B,Q,R)
%
%        calculates the optimal feedback gain matrix K such that the 
%        feedback law:
%
%		      u(k) = -K*x(k)
%
%	      minimizes the cost function:
%
%		      J = Sum {x(k)'*Q*x(k) + u(k)'*R*u(k)}
%
%	      subject to the constraint equation: 
%
%		      x(k+1) = A*x(k) + B*u(k) 
%                
%	      Also returned is S, the steady-state solution to the associated 
%	      algebraic Riccati equation:
%			
%           K = (R+B'*P'*B) \ B'*P*A;      
%           P = A'*P*A - A'*P*B * K + Q;
%
%        See PLL, PLACE, LQR
%
   P = eye(size(Q));

   for (i=1:5000)
      K = (R+B'*P'*B) \ B'*P*A;
      P = A'*P*A - A'*P*B * K + Q;
   end
end
