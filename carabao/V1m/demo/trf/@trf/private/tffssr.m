function [A,B,C,D] = tffssr(arg1,arg2)
%
% TFFSSR State space representation - calculated from polynomials of transfer function
%
%           [A,B,C,D] = tffssr(num,den)
%           [A,B,C,D] = tffssr(Gs)      % same as [A,B,C,D] = ssr(num(Gs),den(Gs))
%
%        Example: Calculate state space model for transfer function
%
%                          5 s^2 + 14 s + 8                  
%                  G(s) = -------------------
%                           1 s^2 + 2 s + 1                  
%
%           [A,B,C,D] = tffssr([5 14 8],[1 2 1]);
%

   if nargin <= 1
      Gs = arg1;
      arg1 = tffnum(Gs);  arg2 = tffden(Gs);
   end
   
   num = arg1;  den = arg2;
   
% remove leading zeros

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
   
% eof