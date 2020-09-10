function oo = test(o,mode)             % Rational Arithmetic Tests     
%
% TEST   Test RAT object arithmetics
%
%          ok = test(o)                % do all tests
%
%          ok = test(o,'Mantissa')     % mantissa arithmetic test
%
%       See also: RAT, ADD, SUB, MUL, DIV, COMP
%
   if (nargin < 2)
      mode = 'All';
   end
   
   switch mode
      case 'Mantissa'
         ok = Mantissa(o);
      case 'All'
         ok = All(o);
      otherwise
         error('bad mode!');
   end
   
   if ok
      fprintf('    test ''%s'' passed!\n',mode);
   else
      fprintf('*** test ''%s'' failed!\n',mode);
   end
   
   if (nargout > 0)
      oo = ok;
   end
end

%==========================================================================
% All Tests
%==========================================================================

function ok = All(o)                   % All Tests                     
   ok = 1;                             % ok = true by default
   ok = ok && Mantissa(o);             % do Mantissa arithmetic tests
end

%==========================================================================
% Mantissa Arithmetic Tests
%==========================================================================

function ok = Mantissa(o)              % Mantissa Arithmetic Tests     
   ok = 1;                             % ok = true by default
   ok = ok && Base10(o);               % standard base 10 test 
   ok = ok && Base100(o);              % standard base 100 test 
   ok = ok && Brute(o);                % Brute Force Test              

   function ok = Base10(o)             % Base 10 Example               
      ok = 1;                          % ok = true by default
      o = base(rat,10);                % start with base 10 example
      
      x = [7 3 8 5];  y = [8 9];
      [q,r] = div(o,x,y);

         % check apriori known results
         
      qq = [8 2]; rr = [8 7];
      ok = ok && Check(o,q,qq,'q = [8 2]');
      ok = ok && Check(o,q,qq,'q = [8 7]');
      
         % check multiplicative commutativity 
         
      p = mul(o,y,q);
      ok = ok && Check(o,p,mul(o,q,y),'y*q = q*y (commutativity)');

      z = add(o,p,r);                  % z = y*q + r should besame as x
      d = sub(o,x,z);                  % difference of x and y*q + r
      ok = ok && Check(o,d,0,'x = y*q + r (cross check)');
   end
   function ok = Base100(o)            % Base 100 Example              
   % Example 1:
   %
   %    [q,r] = mul(o,[41 32 76 78],[58 67])  % divide two mantissa
   %
   %    => q = [70 44], r = [5 30] 
   %
      ok = 1;                          % ok = true by default
      o = base(rat,100);               % start with base 10 example
      
      x = [41 32 76 78];  y = [58 67];
      [q,r] = div(o,x,y);

         % check apriori known results
         
      qq = [70 44];  rr = [5 30];
      ok = ok && Check(o,q,qq,'q = [70 44]');
      ok = ok && Check(o,q,qq,'q = [5 30]');
      
         % check multiplicative commutativity 
         
      p = mul(o,y,q);
      ok = ok && Check(o,p,mul(o,q,y),'y*q = q*y (commutativity)');

      z = add(o,p,r);                  % z = y*q + r should besame as x
      d = sub(o,x,z);                  % difference of x and y*q + r
      ok = ok && Check(o,d,0,'x = y*q + r (cross check)');
   end
end
function ok = General(o,b,x,y,k)       % Base 100 Example              
   global verbose
   if isempty(verbose)
      verbose = 0;                     % verbose on
   end
   
   ok = 1;                             % ok = true by default          
   o = base(rat,b);                    % use b for base

   [q,r] = div(o,x,y);

      % check multiplicative commutativity 

   p = mul(o,y,q);
   ok = ok && Check(o,p,mul(o,q,y),'y*q = q*y (commutativity)');

   z = add(o,p,r);                     % z = y*q + r should besame as x
   d = sub(o,x,z);                     % difference of x and y*q + r
   ok = ok && Check(o,d,0,'x = y*q + r (cross check)');

      % verbose talking

   if (verbose || rem(k,1000)==0)
      fprintf('%5d: [%g',k,x(1));
      for (i=2:length(x))
         fprintf(' %g',x(i));
      end

      fprintf('] = [%g',y(1));
      for (i=2:length(y))
         fprintf(' %g',y(i));
      end

      fprintf('] * [%g',q(1));
      for (i=2:length(q))
         fprintf(' %g',q(i));
      end

      fprintf('] + [%g',r(1));
      for (i=2:length(r))
         fprintf(' %g',r(i));
      end
      fprintf(']\n');
   end
end
function ok = Brute(o)                 % Brute Force Test              
   RandInt;                            % set random seed to zero
   ok = 1;                             % ok = true by default

   tic
   for (k=1:100000)
      x = [];  y = [];
      b = 10^RandInt(6);               % random base

      nx = RandInt(5);
      for (i=1:nx)
         x(i) = RandInt(b) - 1;
      end
      x = x*RandSign;

      ny = RandInt(5);
      for (i=1:ny)
         y(i) = RandInt(b) - 1;
      end
      y = y*RandSign;

      if (all(y==0))                   % beware of division by zero
         y = b-1;                      % fix divison by zero
      end

      ok = General(o,b,x,y,k) && ok;
   end
   toc
end

%==========================================================================
% Helpers
%==========================================================================

function ok = Check(o,a,b,msg)         % Check Wether a = b            
   sgn = comp(o,a,b);
   ok = (sgn == 0);
   
   if ~ok
      beep;
      fprintf('*** test failed: %s\n',msg);
   end
end
function r = RandInt(n)                % Random Integer Number         
%
% RAND   Random number generation
%
%           r = Rand(6)                % random numbers in range 1..6
%           Rand                       % reset random seed
%
   if (nargin == 0)
      rng(0);                          % set random seed to zero
   else
      r = ceil(n*rand);
   end
end
function s = RandSign                  % Random Sign                   
   if (randn >= 0)
      s = +1;
   else
      s = -1;
   end
end
