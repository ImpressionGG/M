function [K,P]=dlqr(o,A,B,Q,R)
%
% DLQR   Discrete Linear Quadratic Regulator design (for discrete-time
%        systems).
%
%	         [K,P] = dlqr(o,A,B,Q,R)
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
%	      subject to the constraint discrete tim equation: 
%
%		      x(k+1) = A*x(k) + B*u(k) 
%                
%	      Also returned is P, the steady-state solution to the associated 
%	      algebraic Riccati equation:
%			
%           K = (R+B'*P'*B) \ B'*P*A;      
%           P = A'*P*A - A'*P*B * K + Q;
%
%        See TRF, LQR
%
   P = 0*Q;
   
   for (i=1:1000)
      K = (R+B'*P'*B) \ B'*P*A;
      P = A'*P*A - A'*P*B * K + Q;
   end

end
