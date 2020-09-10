function z = position(qob,psi,n,z)
%
% POSITION  Calculate positions of n particles which match the probability
%           distribution induced by psi.
%
%              z = Position(qob,psi,n);      % calculate n positions 
%              z = Position(qob,psi,n,[]);   % same as above
%              z = Position(qob,psi,n,z);    % ignore if some(z)
%
%           See also: QUON
%
   if (nargin < 4)
      z = [];
   end
   
   if isempty(z)         % then initialize
      P = prob(psi);
      zspc = zspace(qob);
      F(1) = P(1);
      for k=2:length(P)
         F(k) = F(k-1) + P(k);
      end
      for (k=1:n)
         Fk = 1/(2*n) + (k-1)/n;
         %idx = max(find(F<=Fk));
         %z(k,1) = zspc(idx);
         z(k,1) = interpol(smart,F,zspc',Fk);
      end
   end
   return
end
