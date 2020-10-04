function ok = ismodal(o)               % Is it a Modal Form?           
%
% ISMODAL  Is system representation a modal form?
%
%             ok = ismodal(oo)         % is system a modal form?
%
%          Copyright(c): Bluenetics 2020
%
%          See also: CORASIM, FQR
%
   ok = false;                         % false by default
   if isempty(o)
      return
   end
   
   if ~type(o,{'css','dss'})
      return
   end
   
   oo = Partition(o);
   [A11,A12,A21,A22] = var(oo,'A11,A12,A21,A22');
   I = eye(size(A11));
   
   modal = isequal(A11,0*I) && isequal(A12,I) && ...
           isequal(A21,diag(diag(A21))) && isequal(A22,diag(diag(A22)));
        
   if (modal)
      ok = true;
   end
end

%==========================================================================
% Helper
%==========================================================================

function oo = Partition(o)             % Partition System              
   [A,B,C] = data(o,'A,B,C');

   n = floor(length(A)/2);
   i1 = 1:n;  i2 = n+1:2*n;
   
   A11 = A(i1,i1);  A12 = A(i1,i2);
   A21 = A(i2,i1);  A22 = A(i2,i2);
  
   B1 = B(i1,:);  B2 = B(i2,:);   
   C1 = C(:,i1);  C2 = C(:,i2);
  
   if (norm(B2-C1') ~= 0)
      %fprintf('*** warning: B2 differs from C1''!\n');
   end
   
   M = B2;  a0 = -diag(A21);  a1 = -diag(A22);
   omega = sqrt(a0);  zeta = a1./omega/2;
   
   oo = var(o,'A11,A12,A21,A22',A11,A12,A21,A22);
   oo = var(oo,'B1,B2,C1,C2',B1,B2,C1,C2);
   oo = var(oo,'M,a0,a1,omega,zeta',M,a0,a1,omega,zeta);
end
