function [Phi,H] = c2d(o,A,B,T)        % Convert Continuous to Discrete
%
% C2D	  Conversion of state space models from continuous to discrete time.
%	     [Phi,H] = c2d(o,A,B,T) converts the continuous-time system
%		     .
%		     x = Ax + Bu
%
%	     to the discrete-time state-space system
%
%		     x[n+1] = Phi * x[n] + Gamma * u[n]
%
%	     assuming a zero-order hold on the inputs and sample time T.
%
%       Syntax:
%          o = c2d(o,Ts)
%          [Phi,H] = c2d(o,A,B,Ts)
%
%       Example 1:
%          o = system(o,[0 1;0 0],[0;1],[1 0],0);
%          o = c2d(o,Ts);
%         
%       Example 2:
%          o = system(o,[0 1;0 0],[0;1],[1 0],0);
%          [A,B] = get(o,'system','A,B');
%          [Phi,H] = c2d(o,A,B,Ts);
%          
%       See also: CORASIM
%
   o.argcheck(2,4,nargin)

   if (nargin == 2)
      if ~isequal(type(o),'css')       % continuous state space system
         error('type must be ''css'' (continuous state space)');
      end
      
      T = A;                           % T is arg2 for this syntax
      [A,B,C,D] = get(o,'system','A,B,C,D');     
      abcdcheck(o,A,B,C,D);
      
      [Phi,H] = C2D(o,A,B,T);
      o = set(o,'system','A,B,T',Phi,H,T);
      
      Phi = type(o,'dss');             % set type and assign to out arg
   elseif (nargin == 4)
      [Phi,H] = C2D(o,A,B,T);
   else
      error('2 or 4 input args expected!');
   end
end

%==========================================================================
% Helper Functions
%==========================================================================

function [Phi,H] = C2D(o,A,B,T)                                        
%
% C2D	Conversion of state space models from continuous to discrete time.
%	   [Phi, Gamma] = C2D(A,B,T)  converts the continuous-time system:
%		   .
%		   x = Ax + Bu
%
%	   to the discrete-time state-space system:
%
%		   x[n+1] = Phi * x[n] + Gamma * u[n]
%
%	   assuming a zero-order hold on the inputs and sample time Ts.
%
   abcdcheck(o,A,B);
    
   [m,n] = size(A);
   [m,nb] = size(B);

   S = expm([[A B]*T; zeros(nb,n+nb)]);
   Phi = S(1:n,1:n);
   H = S(1:n,n+1:n+nb);
end
