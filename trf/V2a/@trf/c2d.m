function [Phi,H] = c2d(o,A,B,Ts)       % Convert Continuous to Discrete
%
% C2D   Continuous to discrete transformation
%
%            [Phi,H] = c2d(o,A,B,Ts)
%
%       See also: TRF
%
   [Phi,H] = C2D(A,B,Ts);   
end

%==========================================================================
% Helper Functions
%==========================================================================

function [Phi,H] = C2D(A,B,Ts)
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
   if NargCheck(3,3,nargin)
	   return
   end
   if AbcdCheck(A,B)
	   return
   end
    
   [m,n] = size(A);
   [m,nb] = size(B);
   S = expm([[A B]*Ts; zeros(nb,n+nb)]);
   Phi = S(1:n,1:n);
   H = S(1:n,n+1:n+nb);
end

function err = AbcdCheck(a,b,c,d)
%
% Check that dimensions of A,B,C,D are consistent.
% Give error message if not and return 1. Otherwise return 0.
%
   err = 0;
   [ma,na] = size(a);
   if (ma ~= na)
      errmsg('The A matrix must be square')
      err = 1;
   end
   if (nargin > 1)
      [mb,nb] = size(b);
      if (ma ~= mb)
         errmsg('The A and B matrices must have the same number of rows')
         err = 1;
      end
      if (nargin > 2)
         [mc,nc] = size(c);
         if (nc ~= ma)
            errmsg('The A and C matrices must have the same number of columns')
            err = 1;
         end
         if (nargin > 3)
            [md,nd] = size(d);
            if (md ~= mc)
               errmsg('The C and D matrices must have the same number of rows')
               err = 1;
            end
            if (nd ~= nb)
               errmsg('The B and D matrices must have the same number of columns')
               err = 1;
            end
         end
      end
   end
end

function y = NargCheck(low,high,number)
%
% Check number of input arguments. Give error message and return
% 1 if not between low and high.
%
   y = 0;
   if (number < low)
      errmsg('Not enough input arguments.')
      y = 1;
   elseif (number > high)
      errmsg('Too many input arguments.')
      y = 1;
   end
end
