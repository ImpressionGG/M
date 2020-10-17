function r = aberth(p)
%
% ABERTH    Aberth method - implemented in a Gauss-Seidel style
%           This method gives all the REAL roots of polynomial of any order
%           Very Very Fast and Accurate Method
%
   clc; clear all; close all

   syms x;                       % declearing x as a variable
   P = x^3 -7*x^2 +14*x - 8;     % Polynomial we interested to solve [change it for your case]
   % P = 6*x^5 + 11*x^4 - 33*x^3 - 33*x^2 + 11*x + 6;     % Polynomial we interested to solve [change it for your case]

   Pd = diff(P,x,1);             % Calculation of first order differential
   n = 3;                        % Number of the roots (the order of the equation) [change it for your case]

   err = 0.001; Err = 1;          % err is the accuracy, Err > err is error checking parameter

   z(1,:) = rand(1,n);           % Random Initial Values 
   i = 0;
   while Err >= err 
       i = i + 1;
       for k = 1:n
           p  = double(vpa(subs(P,x,z(i,k))));   % Calculation of p  at z(i) --> p(z(i))
           pd = double(vpa(subs(Pd,x,z(i,k))));  % Calculation of p' at z(i) --> p'(z(i))

           %-----------------
           % Building sumation terms
           S1 = 0; S2 = 0;
           for j = 1:k-1, S1 = S1 + 1/(z(i,k)-z(i+1,j)); end
           for j = i+1:n, S1 = S1 + 1/(z(i,k)-z(i,j)); end
           S = S1 + S2;

           %-----------------
           % Main Aberth Function
           z(i+1,k) = z(i,k) - (p/pd)/(1 - (p/pd)*S);
       end

       %---------------------
       % Error Calculation
       Err = abs(max(z(i+1,:) - z(i,:)));
   end

   %-------------------------
   % Presenting Results
   plot(1:i+1,z,'linewidth',2); grid on; title('Aberth Method in Gauss-Seidel Style')
   xlabel('Number of Iterations'); ylabel('Convergence History')
   legend('Aberth Method')

   disp(['The Root X = [' num2str(z(end,:)) ']'])
   disp(['Max. Error of = ' num2str(Err) ', # Iterations = ' num2str(i)])
end
