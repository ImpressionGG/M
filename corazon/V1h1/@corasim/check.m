function err = check(o,G,mode)
%
% CHECK   Check numeric quality of poles, zeros or eigenvalues. 
%         Standard check is based on double arithmetics. Optional VPA
%         arithmetics can be used
%
%            check(o,G)                % check zero/pole quality of transfer system
%
%            err = check(o,G)          % err = [zerr,perr]zero/pole errors
%
%            err = check(o,G,'Zeros')  % err: column of zero errors
%            err = check(o,G,'Poles')  % err: column of pole errors
%
%            err = check(o,A)          % check eigenvalues
% 
%         Options:
%            digits          % digits of VPA arithmetics for check
%                            % default: 0 means double arithmetics
%
%         Example 1: check quality of eig() function for modal matrices
%            
%            oo = modal(o,a0,a1,B,C,D) % create modal system
%            err = check(opt(oo,'digits',1000),A);
%            disp(norm(err));
%
%         Example 2: check pole quality of a transfer function
%            
%            oo = modal(o,a0,a1,B,C,D) % create modal system
%            G = zpk(oo);
%            err = check(opt(oo,'digits',64),G);
%            disp(norm(err));
%
%         Copyright(c): Bluenetics 2021
%
%         See also: CORASIM, SYSTEM, TRF, ZPK, TRFVAL
%
   digs = opt(o,{'digits',0});
   
      % if digits option is non-zero then we have to proceed with VPA
      % arithmetics
      
   if (digs > 0)
      old = digits(digs);              % redefine VPA digits
   end

   if (nargin < 3 && isa(G,'double'))
      mode = 'EV';
   elseif (nargin < 3)
      mode = 'All';
   end
   
   switch mode
      case 'Poles'
         if (digs > 0)
            G = vpa(G,digs);
         end
         err = CheckPoles(o,G);

      case 'Zeros'
         if (digs > 0)
            G = vpa(G,digs);
         end
         err = CheckZeros(o,G);

      case 'EV'
         if (digs > 0)
            A = vpa(G,digs);
         else
            A = G;                     % try to treat arg2 as a matrix
         end

         if (size(A,1) > 0 && size(A,1) == size(A,2))
            s = eig(A);
            err = Residue(A,s);         
         else
            if (digs > 0)
               digits(old);                     % restore VPA digits
            end
            error('unsupported mode');
         end

      case 'All'
         if (digs > 0)
            G = vpa(G,digs);
         end
         
         errp = CheckPoles(o,G);
         errz = CheckZeros(o,G);

         np = length(errp);
         nz = length(errz);
         n = max(np,nz);

         errp = [errp(:);  zeros(n-np,1)];
         errz = [errz(:); zeros(n-nz,1)];

         err = [errz,errp];

      otherwise
         if (digs > 0)
            digits(old);                     % restore VPA digits
         end
         error('unsupported mode');
   end
      
   if (digs > 0)
      digits(old);                     % restore VPA digits
   end
end

%==========================================================================
% Helper
%==========================================================================

function [a0,a1] = Modal(A)
   ok = false;                         % false by default
   a0 = [];  a1 = [];
   
   n = length(A)/2;
   if (n ~= round(n))
      return;                          % not modal
   end
   
   i1 = 1:n;   i2 = n+1:2*n;
   A11 = A(i1,i1);  A12 = A(i1,i2);  A21 = A(i2,i1);  A22 = A(i2,i2);
   
   if (norm(A11) ~= 0)
      return
   end
   if (norm(A12-eye(size(A11))) ~= 0)
      return
   end
   
   if (norm(A21-diag(diag(A21))) ~= 0)
      return
   end
   if (norm(A22-diag(diag(A22))) ~= 0)
      return
   end
   
   a0 = -diag(A21);
   a1 = -diag(A22);                     % yes, modal!
end
function err = Residue(A,s)            % Residues of Char Equation  
   [a0,a1] = Modal(A);
   if ~isempty(a0)
      one = ones(size(a0))';
      M = (s.*s)*one + s*a1' + ones(size(s))*a0';
      err = min(abs(M));
      err = [err;err];                 % double, since conjugate complex

   else
      I = eye(size(A));

      for (i=1:length(s))
         Mi = s(i)*I - A;
         err(i) = det(Mi);             % eval in char equation
      end
   end
   err = err(:);
end
function err = CheckPoles(o,G)
   [z,p,k] = zpk(G);
   [A,B,C,D] = system(o); 
   err = Residue(A,p);        
end
function err = CheckZeros(o,G)
   [z,p,k] = zpk(G);
   err = trfval(G,z);
end
