function [o,B,C,D,T] = system(o,A,B,C,D,T) % Create or Cast to a System
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
%             oo = system(o,{num,den},-T)   % q-transfer function
%            
%          Retrieve system matrices
%
%             [A,B] = system(o);            % get dynamic & input matrix
%             [A,B,C,D] = system(o);        % get system matrices
%             [A,B,C,D,T] = system(o);      % system matrices & sample time
%
%          Retrieve numerator/denominator
%
%             [num,den] = peek(o);          % get numerator/denominator
%
%          Remark:
%             
%             Discrete state space systems will be marked with type 'dss'
%             and continuous state space systems will be marked with type 
%             'css'
%
%          Options
%
%             sskind         defines the kind of state space representation
%                            during casting (e.g. oo = system(o) call).
%                            valus are: 'standard1', 'standard2' & 'modal'.
%                            default is 'modal'
%
%          See also: CORASIM
%
   if (nargin == 1) && (nargout <= 1)
      o = Cast(o);
      return
   elseif (nargout > 1)
      [A,B,C,D,T] = data(o,'A,B,C,D,T');
      if isempty(A)
         o = Cast(o);                  % auto casting
         [A,B,C,D,T] = data(o,'A,B,C,D,T');
      end
      T = o.either(T,0);
      o = A;                           % output arg
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
         if (T < 0)
            o = type(o,'qtrf');        % q-transfer-function
         elseif (T > 0)
            o = type(o,'ztrf');        % z-transfer-function
         else
            o = type(o,'strf');        % s-transfer-function
         end
      end
      
      o.data = [];                     % clear data
      o = data(o,'num,den,T',num,den,T);
      return
   end
   
      % otherwise we deal with system matrices
   
   if (nargin < 4)
      C = [];  D = [];
   elseif (nargin < 5)
      D = 0*C*B;
   end
   
   abcdcheck(o,A,B,C,D);
   
   o.data = [];
   if (nargin == 6)
      if (T == 0)
         o = type(o,'css');
      else (T > 0)
         o = type(o,'dss');
      end
      o = data(o, 'A,B,C,D,T', A,B,C,D,T);
   else
      T = 0;
      o = type(o,'css');
      o.data = [];
      o = data(o, 'A,B,C,D,T', A,B,C,D,T);
   end
   
   o = var(o, 'A,B,C,D,T', A,B,C,D,T);
end

%==========================================================================
% Cast to a State Space System
%==========================================================================

function oo = Cast(o)                  % Cast to a State Space System   
   if type(o,{'modal'})
      [a0,a1,B,C,D] = data(o,'a0,a1,B,C,D');
      I = eye(length(a0));
      A = [0*I,I; -diag(a0), -diag(a1)];
      oo = system(o,A,B,C,D);
      return
   elseif type(o,{'psiw'})
      [psi,W,D] = data(o,'psi,W,D');
      a1 = psi(:,2);
      a0 = psi(:,3);
      B = [0*W,sqrt(W)]';
      C = [sqrt(W),0*W];
      I = eye(length(a0));
      A = [0*I,I; -diag(a0), -diag(a1)];
      oo = system(o,A,B,C,D);
      return
   end
   
   kind = opt(o,{'sskind','tf2ss'});
  
   switch kind
      case 'tf2ss'
         oo = Tf2ss(o);
      case 'standard1'
         oo = Standard1(o);
      case 'standard2'
         oo = Standard2(o);
      case 'modal'
         oo = Modal(o);
      otherwise
         error('bad ''sskind'' option');
   end
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
   oo.data = [];
   oo = data(oo, 'A,B,C,D,T', A,B,C,D,T);
end
function oo = Standard2(o)             % Brew 2nd Standard Form        
   oo = Standard1(o);
   [AT,CT,BT] = data(oo, 'A,B,C');
   A = AT';  B = BT';  C = CT';        % transpose all matrices
   oo = data(oo, 'A,B,C', A,B,C);
end
function oo = Modal(o)                 % Brew Modal Form               
   [num,den] = peek(o);
   oo = modal(o,num,den);
end
function oo = Tf2ss(o)
%
% TF2SS  Transfer function to state-space conversion.
%
%           o = system(corasim,{num,den})
%           oo = Tf2ss(o) 
%           [A,B,C,D] = data(oo, 'A,B,C,D');
%
%        calculates the state-space representation:
%           .
%           x = Ax + Bu
%           y = Cx + Du
%
%        of the system
%
%                   num(s)
%           G(s) = --------
%                   den(s)
%
%        from a single input. Vector den must contain the coefficients of
%        the denominator in descending powers of s.  Matrix NUM must
%        contain the numerator coefficients with as many rows as there are
%        outputs y. The A,B,C,D matrices are returned in controller
%        canonical form. This calculation also works for discrete systems.
%
%        For discrete-time transfer functions, it is highly recommended to
%        make the length of the numerator and denominator equal to ensure
%        correct results.  You can do this using the function EQTFLENGTH in
%        the Signal Processing Toolbox.  However, this function only handles
%        single-input single-output systems.
%
   if type(o,{'szpk'})
      oo = Zpk2ss(o);
      return
   end
   
   [num,den] = peek(o);                % peek numerator/denominator
   
      % null system - Both numerator and denominator are empty
      
   if isempty(num) && isempty(den)
       a = zeros(0,'like',den);
       b = [];
       c = zeros(0,'like',num) + zeros(0,'like',den);
       d = zeros(0,'like',num) + zeros(0,'like',den);
       oo = data(oo, 'A,B,C,D', a,b,c,d);
       return
   end
   
      % dealing with a non-null system
      
   denRow = den(:).';

    % Index of first non zero element of denominator

   startIndexDen = find(denRow,1);

    % Denominator should not be zero or empty

   if isempty(startIndexDen)
      error('invalid range');
   end

    % strip denominator of leading zeros

   denStrip = denRow(startIndexDen(1):end);
   [mnum,nnum] = size(num);
   nden = size(denStrip,2);

   % check for proper numerator

   if (nnum > nden)
      if any(num(:,1:(nnum - nden)) ~= 0,'all')
         error('denominator invalid order');
      end

        % try to strip leading zeros to make proper

      numStrip = num(:,(nnum-nden+1):nnum);
   else

        % pad numerator with leading zeroes, to make it have same
        % number of columns as the denominator

     numStrip = [zeros(mnum,nden-nnum) num];
   end

      % Normalize numerator and denominator such that first element of
      % Denominator is one

   numNorm = numStrip./denStrip(1);
   denNorm = denStrip./denStrip(1);

   if mnum == 0
     d = zeros(0,'like',numNorm);
     c = zeros(0,'like',numNorm);
   else
     d = numNorm(:,1);
     c = numNorm(:,2:nden) - numNorm(:,1) * denNorm(2:nden);
   end

   if nden == 1
     a = zeros(0,'like',denNorm);
     b = [];
     c = zeros(0,'like',numNorm);
   else
     a = [-denNorm(2:nden);eye(nden-2,nden-1)];
     b = eye(nden-1,1);
   end
   
      % set output args and converted type
      
   oo = data(o, 'A,B,C,D', a,b,c,d);
   switch oo.type
      case {'strf','css'}              % continuous system
         oo.type = 'css';              % output type: continuous SS
      case {'ztrf','dss'}              % discrete system
         oo.type = 'dss';              % output type: discrete SS
      otherwise
         error('bad type');
   end
end

%==========================================================================
% ZPK to a State Space System
%==========================================================================

function oo = Zpk2ss(o)
%
% ZPK2SS    Convert ZPK to State Space Representation
%
%              oo = Zpk2ss(o)
%
%           Theory:
%
%                     s2 + b1*s + b0                  s2 + p1*s + p0
%           G1(s) = ------------------       G2(s) = -----------------
%                     s2 + a1*s + a0                  s2 + q1*s + q0
%
%           x1` = A1*x1 + B1*u          x2` = A2*x2 + B2*z 
%           z   = C1*x1 + D1*u          y   = C2*x2 + D2*z
%
%           x2` = A2*x2 + B2*(C1*x1 + D1*u)
%            y  = C2*x2 + D2*(C1*x1 + D1*u)
%
%        [x1`]   [ A1     0 ]   [x1]   [ B1  ]
%        [   ] = [          ] * [  ] + [     ] * u
%        [x2`]   [B2*C1   A2]   [x2]   [B2*D1]
%
%                               [x1]
%        y     = [D2*C1   C2] * [  ] +  D2*D1*u
%                               [x2]
%
%        a) representation of 2/2 system
%
%                     s2 + b1*s + b0            (b1-a1)*s + (b0-a0)
%            G(s) = ------------------  =  1 + ---------------------
%                     s2 + a1*s + a0             s2 + a1*s + a0
%
%        [x1`]   [ 0     1 ]   [x1]   [ 0 ]
%        [   ] = [         ] * [  ] + [   ] * u
%        [x2`]   [-a0   -a1]   [x2]   [ 1 ]
%
%                              [x1]
%          y   = [ b0    b1] * [  ] +   1   * u
%                              [x2]
%
%        and for a complex pole/zero pair z,z' and p,p':
%
%        (s-z)*(s-z') = s2 - s(z+z') + z*z' => b1 = -z-z', b0 = z*z' 
%        (s-p)*(s-p') = s2 - s(p+p') + p*p' => a1 = -p-p', a0 = p*p' 
%
%        b) representation of 0/2 system
%
%                            1
%            G(s) = ------------------
%                     s2 + a1*s + a0
%
%        [x1`]   [ 0     1 ]   [x1]   [ 0 ]
%        [   ] = [         ] * [  ] + [   ] * u
%        [x2`]   [-a0   -a1]   [x2]   [ 1 ]
%
%                              [x1]
%          y   = [ 1     0 ] * [  ] +   0   * u
%                              [x2]
   assert(type(o,{'szpk'}));
   [zeros,poles,K] = zpk(o);
   
   m = length(zeros);
   n = length(poles);
   
   if (rem(m,2) ~= 0 || rem(n,2) ~= 0)
      error('even number of poles/zeros expected');
   end
   
      % sort zeros and poles
      
   zeros = Sort(zeros);
   poles = Sort(poles);
   
      % build up system matrices
   
   A = [];  B = [];  C  = [];  D = [];
   
   if (m > n)
      error('transfer function not proper, cannot proceed');
   elseif (n == 0)
      oo = system(o,A,B,C,K);
      return
   elseif (n >= m+2)          % good for SPM's modal form
      b0 = 1; b1 = 0;
      [a0,a1] = Coeff(poles(1),poles(2));
      poles(1:2) = [];
      n = length(poles);      % refresh
      A = [0 1; -a0 -a1];  B = [0;1];  C = [b0 b1];  D = 0;
   end
   
   for (i=1:2:n)
      A1 = A;  B1 = B;  C1 = C;  D1 = D;
      
      [a0,a1] = Coeff(poles(i),poles(i+1));
      
      if (i < m)              % zeros available
         [b0,b1] = Coeff(zeros(i),zeros(i+1));
         b0 = b0-a0;  b1 = b1 - a1;
         D2 = 1;
      else
         b0 = 1;  b1 = 0;
         D2 = 0;
      end
      
      A2 = [0 1; -a0 -a1]; B2 = [0;1]; C2 = [b0 b1];
      
         % compose next bigger system matrices
         
      if isempty(A1)
         A = A2;  B = B2;  C = K*C2;  D = K*D2;
      else
         A = [A1 0*B1*C2; B2*C1 A2];
         B = [B1; B2*D1];
         C = [D2*C1 C2];
         D = D2*D1;
         
            % the following transformation is possible:
            % z = T\x or x = T*z
            % with x`= A*x + B*u and y = C*x + D*u
            % we get: x`= T*z` = A*T*z + B*u and y = C*T*z + D*u
            % or z` = (T\A*T)*z + (T\B)*u and y = (C*T)*z + D*u
         
         T = eye(size(A));
         N = length(A)/2;
         idx = [1:N-1, [N+1:2*N-1, N], 2*N];
         T = T(idx,:);
         
         A = T\A*T;  B = T\B;  C = C*T;
         
            % v1`= -65*x1 - 14*v1
            % v2' = 1*x1 -29*x2 -4*v2 
      end      
   end
   oo = system(o,A,B,C,D);
   
   function s = Sort(s)
      [~,idx] = sort(real(s));   % sort by real part
      s = s(idx);
      
         % within same real part imaginary part must also be sorted
         
      dirty = 1;
      while (dirty)
         dirty = 0;       % maybe this time do not get dirty
         for (i=1:length(s)-1)
            s1 = s(i);  s2 = s(i+1);
            if (real(s1) == real(s2))
               if (abs(imag(s1)) > abs(imag(s2)))
                  s(i) = s2;  s(i+1) = s1;       % swap
                  dirty = 1;
               end
            end
         end
      end
   end
   function [a0,a1] = Coeff(s1,s2)
      assert(real(s1)==real(s2));
      assert(imag(s1)==-imag(s2));

      a1 = -real(s1) - real(s2);
      a0 = s1*s2;
      assert(imag(a0)==0);
   end
end

