function [Kcrit,stable,K] = nyquist(o,K)
%
% NYQUIST  Return stability region for set of K values
%
%             [Kcrit,stable] = nyquist(o,K)
%             [Kcrit,stable,K] = nyquist(o)
%
%          Theory: given L0(s) := mu*G31(s)/G33(s) consider the complex
%          frequency response curve
%
%             N(jw) := 1 + L0(jw)  =  1 + mu*G31(jw)/G33(jw)
%
   if (nargin < 2)
      K = logspace(-3,3,1000);
   end
   
   omega = cache(o,'nyq.omega');
   L0jw = cache(o,'nyq.L0jw');
   
   stable = 0*K;
   for (i=1:length(K))
      Njw = 1 + K(i)*L0jw;
      phi = angle(Njw);
      U = sum(diff(phi)) / (2*pi);
      
      if (U > 0.5)
         stable(i) = 0;
      elseif (U < 0.5)
         stable(i) = 1;
      else
         stable(i) = NaN;
      end
   end
   
      % find critical K
      
   idx = find(stable ~= 1);
   if isempty(idx)
      Kcrit = inf;
   else
      Kcrit = K(idx(1)-1);
   end
end

   
   