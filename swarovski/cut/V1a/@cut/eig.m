function lambda = eig(o)
%
% EIG   Get eigenvalues of the two linearized systems
%
%          lambda = eig(o)     % 4x2 eigenvalue matrix
%
%       See also: CUT, HOGA1, HOGA2
%
   [A1,A2] = model(o);
   lambda = [eig(A1),eig(A2)];
end
