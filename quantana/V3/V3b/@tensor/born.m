function W = born(T,psi0,arg3)
%
% BORN       Weight calculation according to Born rule. Let T be a unitary
%            operator on Hilbert space H representing time transition, psi
%            being a vector of H and psi0 and initial state of H. 
%
%               H = space(tensor,[1 3 5; 2 4 6]);
%               T = operator(H,'>>');
%               psi0 = H('3');
%
%            Then the Born rule assigns a weight to the vector psi with
%            respect to initial state psi0 and transition operator T:
%
%               psi = normalize(H('4')+H('5'));
%               W = born(T,psi0,psi) 
%
%            Replace vector psi by a decomposition (split) S = {P{k}}. Then
%            the Born rule returns a vector (matrix) of probabilities
%            according to the label matrix of S.
%
%               S = split(H,labels(H));
%               p = born(T,psi0,S);
%
%            See also: TENSOR, PROJECTOR, SPLIT, CHAIN
%
   if (nargin < 3)
      error('3 input args expected!');
   end
   
   if ~property(T,'operator')
      error('arg1 must be a unitary operator!');
   end
   
   if ~property(T,'unitary')
      error('arg1 must be a unitary operator!');
   end

   if ~property(psi0,'vector')
      error('arg2 must be a vector!');
   end
   
   if (norm(psi0) ~= 1)
      error('psi0 (arg2) must be normalized!');
   end
   
% dispatch now depending on the type of arg3

   switch format(arg3)
      case '#VECTOR'
         psi = arg3;

         if (norm(psi) ~= 1)
            error('psi (arg3) must be normalized!');
         end
         
         Tpsi0 = T*psi0; 
         W = abs(psi'*Tpsi0)^2;
         
      case '#SPLIT'
         S = arg3;
         Tpsi0 = T*psi0; 

         list = property(S,'list');
         [m,n] = size(list);
         W = zeros(m,n);
         
         for (i=1:m)
            for (j=1:n)
               T = list{i,j};
               idx = property(T,'index');
               H = space(T);
               W(i,j) = 0;
               for (k=1:length(idx))
                  V = vector(H,idx(k));
                  v = V+0; tpsi0 = Tpsi0+0;      % for debug
                  W(i,j) = W(i,j)+abs(V'*Tpsi0)^2;
               end
            end
         end
         
         assert(abs(sum(sum(W))-1) < 30*eps);
         
      otherwise
         error(['bad format of arg3: ',format(arg3)]);
   end
   
   return
end
