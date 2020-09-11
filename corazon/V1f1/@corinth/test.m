function oo = test(o,varargin)         % CORINTHian Arithmetic Tests   
%
% TEST   Test CORINTHian arithmetics
%
%           ok = test(o)               % do all tests
%
%           test(o,'Menu');            % setup test menu
%
%           ok = test(o,'Mantissa')    % mantissa arithmetic test
%           ok = test(o,'Number')      % number construction test
%           ok = test(o,'Poly')        % polynomial arithmetic test
%           ok = test(o,'Cast')        % casting test
%           ok = test(o,'Gcd')         % GCD test
%
%           ok = test(o,'Million')     % 1 million mantissa tests
%           ok = test(o,'Transition')  % transition matrix
%
%           ok = test(0,'Timing')      % timing test
%
%        Options:
%          
%           number.mantissa:           number of mantissa test loops
%           number.gcd:                number of GCD test loops
%
%        Copyright Bluenetics 2020
%
%        See also: CORINTH, ADD, SUB, MUL, DIV, COMP
%
   [gamma,o] = manage(o,varargin,@All,@Menu,...
                      @Mantissa,@Number,@Poly,@Cast,@Timing,@Gcd,...
                      @Million,@Transition);
   
      % copy verbose (control) option to global variable
      
   global CorinthVerbose
   CorinthVerbose = opt(o,{'control.verbose',2});
   
      % call local function (menu setup, or specific test)
      
   ok = gamma(o);
   
      % post processing ...
      
   if ~isobject(ok)
      fprintf('\nTest Summary:\n');

      if ok
         fprintf('    test ''%s'' passed!\n',char(gamma));
      else
         fprintf('*** test ''%s'' failed!\n',char(gamma));
      end
   end
   
   if (nargout > 0)
      oo = ok;
   end   
end

%==========================================================================
% Setup Test Menu
%==========================================================================

function oo = Menu(o)
   oo = mitem(o,'All',{@test,'All'});
   
   oo = mitem(o,'-');
   oo = mitem(o,'Mantissa',{@test,'Mantissa'});
   oo = mitem(o,'Number',  {@test,'Number'});
   oo = mitem(o,'Poly',    {@test,'Poly'});
   oo = mitem(o,'Cast',    {@test,'Cast'});
   oo = mitem(o,'Gcd',     {@test,'Gcd'});
   oo = mitem(o,'-');
   oo = mitem(o,'Million',{@test,'Million'});
   oo = mitem(o,'Transition Matrix',{@test,'Transition'});
end

%==========================================================================
% All Tests
%==========================================================================

function ok = All(o)                   % All Tests                     
   ok = 1;                             % ok = true by default
   ok = ok && test(o,'Mantissa');      % mantissa arithmetic test
   ok = ok && test(o,'Number');        % number construction test
   ok = ok && test(o,'Poly');          % polynomial test
   ok = ok && test(o,'Cast');          % casting test
   ok = ok && test(o,'Gcd');           % polynomial gcd test
end

%==========================================================================
% Mantissa Arithmetic Tests
%==========================================================================

function ok = Mantissa(o)              % Mantissa Arithmetic Tests     
   fprintf('Mantissa arithmetic test ...\n');
   o.profiler([]);

   ok = 1;                             % ok = true by default
   ok = ok && Base10(o);               % standard base 10 test 
   ok = ok && Base100(o);              % standard base 100 test 
   ok = ok && Brute(o);                % Brute Force Test              

   o.profiler;                         % show profiling results

   function ok = Base10(o)             % Base 10 Example               
      ok = 1;                          % ok = true by default
      o = base(corinth,10);            % start with base 10 example
      
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
      o = base(corinth,100);           % start with base 10 example
      
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
   ok = 1;                             % ok = true by default          
   o = base(corinth,b);                % use b for base

   [q,r] = div(o,x,y);

      % check multiplicative commutativity 

   p = mul(o,y,q);
   ok = ok && Check(o,p,mul(o,q,y),'y*q = q*y (commutativity)');

   z = add(o,p,r);                     % z = y*q + r should besame as x
   d = sub(o,x,z);                     % difference of x and y*q + r
   ok = ok && Check(o,d,0,'x = y*q + r (cross check)');

      % verbose talking

   if (rem(k,1000)==0)
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
   number = opt(o,{'number.mantissa',10000});
   
   for (k=1:number)
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
% Number Construction Tests
%==========================================================================

function ok = Number(o)                % Number Construction Test      
   fprintf('Number construction test ...\n');

   ok = 1;                             % ok = true by default
   ok = ok && BaseE1(o);               % standard base 1e1 test 
   ok = ok && BaseE2(o);               % standard base 1e2 test 
   ok = ok && BaseE6(o);               % standard base 1e6 test 

   function ok = BaseE1(o)             % Base 1e1 Example               
      ok = 1;                          % ok = true by default
      o = base(corinth,1e1);           % base 1e1 object

      p = number(o,pi);
      q = number(o,[8 8 4 2 7 9 7 1 9 0 0 3 5 5 5],...
                   [2 8 1 4 7 4 9 7 6 7 1 0 6 5 6]);
     ok = ok && (comp(p,q)==0);        % test: p == q
     p
   end
   function ok = BaseE2(o)             % Base 1e2 Example               
      ok = 1;                          % ok = true by default
      o = base(corinth,1e2);           % base 1e2 object

      p = number(o,pi);
      q = number(o,[8 84 27 97 19 00 35 55],...
                   [2 81 47 49 76 71 06 56]);
      ok = ok && (comp(p,q)==0);        % test: p == q
      p
   end
   function ok = BaseE6(o)             % Base 1e6 Example               
      ok = 1;                          % ok = true by default
      o = corinth;                     % base 1e6 object

      p = number(o,pi);
      q = number(o,[107944 301636 176147],...
                   [34359 738368],-1);
      ok = ok && (comp(p,q)==0);       % test: p == q
      p
   end
end

%==========================================================================
% Polynomial Arithmetic Tests
%==========================================================================

function ok = Poly(o)                  % Polynomial Arithmetic Test    
   fprintf('Polynomial arithmetic test ...\n');

   ok = 1;                             % ok = true by default
   ok = ok && Special(o);              % standard base 10 test 
   ok = ok && Base10(o);               % standard base 10 test 
   ok = ok && Base100(o);              % standard base 100 test 

   function ok = Special(o)            % Special Polynomial Test       
   %
   % SPECIAL  This example executed once with a bug
   %
      ok = 1;
      o = base(o,100);
      
      c0 = [6 8];
      c1 = [7 8 9];    c01 = conv(c0,c1);
      c2 = [17 56 2];  c02 = conv(c0,c2);
      
      p0 = poly(o,c0);
      
      p1 = poly(o,c1);  
      p01 = poly(o,c01);  
      m01 = mul(p0,p1);

            
      p2 = poly(o,c2);  
      p02 = poly(o,c02);  
      m02 = mul(p0,p2);     

      ok = ok && iszero(m01-p01);
      ok = ok && iszero(m02-p02);
   end
   function ok = Base10(o)             % Base 10 Example
      ok = 1;                          % ok = true by default
      o = base(corinth,10);            % base 10 object

      a = poly(o,[1 5 6]);
      b = poly(o,[1 2 1]);
      c = poly(o,conv([1 5 6],[1 2 1]));
      
      ab = a*b;
      ok = ok && (comp(ab,c)==0);      % test c-a*b against zero!
      a,b,c
   end
   function ok = Base100(o)            % Base 100 Example              
      ok = 1;                          % ok = true by default
      o = base(corinth,100);           % base 100 object

      a = poly(o,[1 5 6]);
      b = poly(o,[1 2 1]);
      c = poly(o,conv([1 5 6],[1 2 1]));
      
      ab = a*b;
      ok = ok && (comp(ab,c)==0);      % test c-a*b against zero!
   end
end

%==========================================================================
% Casting Tests
%==========================================================================

function ok = Cast(o)                  % Casting Test                  
   fprintf('Casting test ...\n');

   ok = 1;                             % ok = true by default
   ok = ok && IsZero100(o);            % base 100 IsZero test 
   ok = ok && IsEye100(o);             % base 100 IsEye test 
   ok = ok && Cast100(o);              % base 100 casting test 

   function ok = IsZero100(o)          % Base 100 IsZero Test         
      ok = 1;                          % ok = true by default
      o = base(corinth,100);           % base 100 object

      ok = ok && iszero(number(o,0));
      ok = ok && ~iszero(number(o,1));
      
      ok = ok && iszero(poly(o,[0]));
      ok = ok && iszero(poly(o,[0 0 0 0]));
      ok = ok && ~iszero(poly(o,[1]));

      ok = ok && iszero(poly(o,[0]));
      ok = ok && iszero(poly(o,[0 0 0 0]));
      ok = ok && ~iszero(poly(o,[1]));

      ok = ok && iszero(matrix(o,[0]));
      ok = ok && iszero(matrix(o,zeros(3)));

      ok = ok && ~iszero(matrix(o,[1]));
      ok = ok && ~iszero(matrix(o,eye(3)));
      ok = ok && ~iszero(matrix(o,[0 0 0 1]'*[0 0 1]));
   end
   function ok = IsEye100(o)           % Base 100 IsEye Test         
      ok = 1;                          % ok = true by default
      o = base(corinth,100);           % base 100 object

      ok = ok && ~iseye(number(o,0));
      ok = ok && iseye(number(o,1));
      
      ok = ok && iseye(poly(o,[1]));
      ok = ok && iseye(poly(o,[0 0 0 1]));
      ok = ok && ~iseye(poly(o,[0]));

      ok = ok && iseye(ratio(o,[88],[88]));
      ok = ok && iseye(ratio(o,[0 0 0 1],[0 0 1]));
      ok = ok && ~iseye(ratio(o,[0],[1]));

      ok = ok && iseye(matrix(o,[1]));
      ok = ok && iseye(matrix(o,eye(3)));
      ok = ok && ~iseye(matrix(o,[0]));
      ok = ok && ~iseye(matrix(o,0*eye(3)));
      ok = ok && ~iseye(matrix(o,[0 0 0 1]'*[0 0 1]));
   end
   function ok = Cast100(o)            % Base 100 Casting Test         
      ok = 1;                          % ok = true by default
      o = base(corinth,100);           % base 100 object
      
      on1 = number(o,pi);
      op1 = poly(on1);
      or1 = ratio(op1);
      om1 = matrix(or1);
      
      om2 = matrix(on1);
      or2 = ratio(om2);
      op2 = poly(or2);
      on2 = number(op2);
      
      ok = ok && (comp(on1,on2)==0);   % test on1-on2 against zero!
      om2,or2,op2,on2
   end
end

%==========================================================================
% Casting Tests
%==========================================================================

function ok = Gcd(o)                   % GCD Test                  
   RandInt;                            % set random seed to zero
   
   fprintf('GCD test ...\n');

   ok = 1;                             % ok = true by default
   %ok = ok && PolyGcd(o);             % polynomial GCD test 

   N = opt(o,{'number.gcd',4});        % number of GCD test loops
   M = N+2;
M=N;   
   
   for (i=1:N)
      b = 10^RandInt(6);

      m0 = RandInt(3);
      m1 = RandInt(3);
      m2 = RandInt(3);

      msg = sprintf('%g of %g: RandPolyGcd(%g,%g,%g) @ base %g',...
                    i,M, m0,m1,m2, b); 
      fprintf('%s\n',msg);

      ok = ok && RandPolyGcd(o,m0,m1,m2,b);
   end

   for (i=N+1:M)                       % 2nd Bunch of Test Runs        
      b = 1e6;                         % this time fixed base

      m0 = RandInt(5);
      m1 = RandInt(8);
      m2 = RandInt(8);

      msg = sprintf('%g of %g: RandPolyGcd(%g,%g,%g) @ base %g',...
                    i,M, m0,m1,m2, b); 
      fprintf('%s\n',msg);

      ok = ok && RandPolyGcd(o,m0,m1,m2,b);
   end
   
   o.profiler;                         % show profiling results

   fprintf('Polynomial GCD tests: %s\n',o.iif(ok,'OK','FAIL'));

   function ok = PolyGcd(o)            % Polynomial GCD Test           
      ok = 1;                          % ok = true by default
      o = base(corinth,100);           % base 100 object

      p0 = poly(o,[1 2]);
      p1 = poly(o,conv([1 2],[1 2 3]));
      p2 = poly(o,conv([1 2],[4 5]));
      
      cf = gcd(p1,p2);
      [q1,r1] = div(p0,cf);
      [q2,r2] = div(cf,p0);
      
      ok = ok && iszero(r1) && iszero(r2);
   end
   function ok = RandPolyGcd(o,m0,m1,m2,b)% Random Polynomial GCD Test 
      ok = 1;                          % ok = true by default
            
      o = base(o,b);                   % base 1e1,1e2,...1e6 object

      for (k=1:m0)
         mag = 10^(RandInt(11)-6);       % magnitude
         c0(k) = mag*randn;
      end

      for (k=1:m1)
         mag = 10^(RandInt(11)-6);       % magnitude
         c1(k) = mag*randn;
      end
      
      for (k=1:m2)
         mag = 10^(RandInt(11)-6);       % magnitude
         c2(k) = mag*randn;
      end
      
      p0 = poly(o,c0);
      p1 = poly(o,c1);
      p2 = poly(o,c2);

      %p1 = poly(o,conv(c0,c1));
      %p2 = poly(o,conv(c0,c2));

      p10 = mul(p1,p0);
      p20 = mul(p2,p0);

      p10 = inherit(p10,o);
      p20 = inherit(p20,o);
      
      [q1,r1] = div(p10,p0);          % must be dividable without remainder
      [q2,r2] = div(p20,p0);          % must be dividable without remainder
      
      ok = ok && iszero(r1) && iszero(r2);

      cf = gcd(p10,p20);
      [q1,r1] = div(p0,cf);          % must be dividable without remainder
      [q2,r2] = div(cf,p0);           % must be dividable without remainder
      
      ok = ok && iszero(r1) && iszero(r2);
   end
end

%==========================================================================
% Timing Test
%==========================================================================

function ok = Timing(o)                % Timing Test                   
   fprintf('Timing test ...\n');

   ok = 1;                             % ok = true by default

   n = 100;
 
        % zip
      
   tic;
   for (i=1:n)
      for (j=1:n)
         bag = zip(o);
      end
   end
   elapse = toc;
   fprintf('%g x %g zip: %g s\n',n,n,elapse);
 
         % unzip
      
   tic;
   for (i=1:n)
      for (j=1:n)
         oo = unzip(o,bag);
      end
   end
   elapse = toc;
   fprintf('%g x %g zip: %g s\n',n,n,elapse);
 
      % test with strings
      
   tic;
   for (i=1:n)
      for (j=1:n)
         str = 'junk';
         M{i,j} = str;
      end
   end
   elapse = toc;
   fprintf('%g x %g strings: %g s\n',n,n,elapse);

      % test with structures
      
   tic;
   for (i=1:n)
      for (j=1:n)
         data.type = 'number';
         data.expo = 0;
         data.num = i;
         data.den = j;
         
         M{i,j} = data;
      end
   end
   elapse = toc;
   fprintf('%g x %g structs: %g s\n',n,n,elapse);
   
      % test with cells
      
   tic;
   for (i=1:n)
      for (j=1:n)
         cell = {'number',0,i,j};
         M{i,j} = cell;
      end
   end
   elapse = toc;
   fprintf('%g x %g cells: %g s\n',n,n,elapse);
   
      % test with objects
      
   tic;
   for (i=1:n)
      for (j=1:n)
         oo = corinth(i,j);         
         M{i,j} = oo;
      end
   end
   elapse = toc;
   fprintf('%g x %g corinth: %g s\n',n,n,elapse);

      % test with packed objects
      
   tic;
   for (i=1:n)
      for (j=1:n)      
         data.type = o.type;
         data.expo = 0;
         data.num = i;
         data.den = j;
         M{i,j} = data;
      end
   end
   elapse = toc;
   fprintf('%g x %g packed object: %g s\n',n,n,elapse);

      % test with structs
      
   tic;
   for (i=1:n)
      for (j=1:n)
         data.type = 'number';
         data.expo = 0;
         data.num = i;
         data.den = j;
         
         M{i,j} = data;
      end
   end
   elapse = toc;
   fprintf('%g x %g structs: %g s\n',n,n,elapse);

end

%==========================================================================
% Million
%==========================================================================

function ok = Million(o)               % 1 Million Mantissa Tests      
   fprintf('1 million mantissa test runs ...\n');
   fprintf('profiler and verbose mode deactivated!\n');
   
   o = opt(o,'number.mantissa',1e6);   % set number option to 1 Mio
   o = opt(o,'control.verbose',0);
   mode = o.profiler('off');
   
   ok = Mantissa(o);
   o.profiler(mode);
end

%==========================================================================
% Transition Matrix
%==========================================================================

function ok = Transition(o)            % transition Matrix             
   RandInt;                            % set random seed to zero
   ok = 1;
   
   fprintf('Transition matrix ...\n');

   o = base(corinth,1e6);
   
   fprintf('calculate: A = matrix(o,magic(3)) ...\n');
   A = matrix(o,magic(3))
   
   fprintf('calculate: B = trans(A) ...\n');
   Phi = trans(A)
      
   fprintf('calculate: B = sI-B ...\n');
   s = poly(o,[1 0]);
   I = matrix(o,eye(3));
   sI = s*I;
   B = sI - A
   
   fprintf('check: iseye((s*I-A)*Phi) ...\n');
   I = B*Phi
   ok = ok && iseye(I);
   
   fprintf('check: iseye(Phi*(s*I-A)) ...\n');
   I = Phi*B
   ok = ok && iseye(I);
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
