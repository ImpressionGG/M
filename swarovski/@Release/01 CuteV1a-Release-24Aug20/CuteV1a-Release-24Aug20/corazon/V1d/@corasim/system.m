function o = system(o,A,B,C,D,T)       % Create or Cast to a System    
%
% SYSTEM   Setup a system for simulation
%
%             oo = system(o)                % cast to a state space system
%
%             oo = system(o,A,B,C,D)        % continuous state space system
%             oo = system(o,A,B,C,D,T)      % dscrete state space system
%
%             oo = system(o,{num,den})      % s-transfer function
%             oo = system(o,{num,den},T)    % z-transfer function
%            
%          Remark:
%             
%             Discrete state space systems will be marked with type 'dss'
%             and continuous state space systems will be marked with type 
%             'css'
%
%          See also: CORASIM
%
   if (nargin == 1)
      o = Cast(o);
      return
   end
   
   
   o.argcheck(2,6,nargin);
   
      % in case of cell args we have to interprete arg2 as a pair of
      % numerator/denominator for a transfer function. Store as num/den
      
   if iscell(A)
      o.argcheck(2,3,nargin);
      if (length(A) ~= 2)
         error('cell pair (num/den) expected for arg2')
      end
      num = A{1};  den = A{2};
      if (nargin < 3)
         T = 0;
         o = type(o,'strf');           % s-transfer-function
      else
         T = B;
         if (length(T) ~= 1)
            error('scalar expected for samplig time (arg3)');
         end
         o = type(o,'ztrf');           % z-transfer-function
      end
      o = set(o,'system','num,den,T',num,den,T);
      return
   end
   
      % otherwise we deal with system matrices
   
   if (nargin < 4)
      C = [];  D = [];
   elseif (nargin < 5)
      D = zeros(size(C,1),size(B,2));
   end
   
   abcdcheck(o,A,B,C,D);
   
   if (nargin == 6)
      o = type(o,'dss');
      o = set(o,'system','A,B,C,D,T', A,B,C,D,T);
      o.data = [];
   else
      o = type(o,'css');
      o = set(o,'system', 'A,B,C,D', A,B,C,D);
      o.data = [];
   end
end

%==========================================================================
% Cast to a State Space System
%==========================================================================

function oo = Cast(o)                  % Cast to a State Space System
   oo = Standard1(o);
end
function oo = Standard1(o)             % Brew 1st Standard Form        
%
% STANDARD1
%
%        Example: Calculate state space model for transfer function
%
%                          5 s^2 + 14 s + 8                  
%                  G(s) = -------------------
%                           1 s^2 + 2 s + 1                  
%
%           oo = system(o,{[5 14 8],[1 2 1]}
%           oo = Standard1(oo)
%           [A,B,C,D] = var(oo,'A,B,C,D')
%
   switch o.type
      case 'strf'                      % s-type transfer function
         typ = 'css';                  % output type: continuous SS
      case 'ztrf'                      % z-type transfer function
         typ = 'dss';                  % output type: discrete SS
      otherwise
         error('no transfer function');
   end
   
      % fetch num/den and remove leading zeros
      
   [num,den,T] = get(o,'system','num,den,T');
   
   while (abs(den(1)) <= eps) den(1) = []; end
   while (abs(num(1)) <= eps) num(1) = []; end
   
      % determine degrees and check for proper system
   
   n = length(den)-1;
   m = length(num)-1;
      
   if (m > n)
      error('degree of numerator has to be less equal degree of denominator!'); 
   end
   
      % adjust and normalize numerator
      %
      %    num = [b(n), b(n-1), ...,b(1), b(0)]
      %    num = [a(n), a(n-1), ...,a(1), a(0)]
   
   den = den(:)';  
   num = [zeros(1,n-m), num(:)'];
   
   den = den/den(1);  num = num/den(1); 
   
      % get coefficients   

   a = den(n+1:-1:2);
   b = num(n+1:-1:2);
   
      % setup state space matrices
   
   A = eye(length(a));
   B = A(:,length(A)); 
   A = [A(2:length(A),:);-a];
   D = num(1);
   C = b-D*a;
   
      % store back to object
      
   oo = type(o,typ);                   % set output type ('css' or 'dss')
   oo.par.system = [];
   oo = set(oo,'system','A,B,C,D,T',A,B,C,D,T);
end
