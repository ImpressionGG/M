function oo = brew(o,varargin)
%
% BREW   Brew a CORASIM object
%
%           oo = brew(o,'Standard1')   % provide 1st standard form matrices
%           oo = brew(o,'Standard2')   % provide 2nd standard form matrices
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORASIM, SYSTEM
%
   [gamma,oo] = manage(o,varargin,@All,@Standard1,@Standard2);
   oo = gamma(oo);

end

%==========================================================================
% Brew All
%==========================================================================

function oo = All(o)
   error('implementation');
end

%==========================================================================
% Brew Standard Forms
%==========================================================================

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
   oo = var(oo,'A,B,C,D,T',A,B,C,D,T);
end
function oo = Standard2(o)             % Brew 2nd Standard Form        
   error('implementation');
end
