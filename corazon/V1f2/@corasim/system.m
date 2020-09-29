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
   if (nargin == 1) && (nargout == 1)
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
      o = data(o,'num,den,T',num,den,T);
      return
   end
   
      % otherwise we deal with system matrices
   
   if (nargin < 4)
      C = [];  D = [];
   elseif (nargin < 5)
      D = zeros(size(C,1),size(B,2));
   end
   
   abcdcheck(o,A,B,C,D);
   
   o.data = [];
   if (nargin == 6)
      o = type(o,'dss');
      o = data(o, 'A,B,C,D,T', A,B,C,D,T);
   else
      T = 0;
      o = type(o,'css');
      o.data = [];
      o = data(o, 'A,B,C,D', A,B,C,D);
   end
   
   o = var(o, 'A,B,C,D,T', A,B,C,D,T);
end

%==========================================================================
% Cast to a State Space System
%==========================================================================

function oo = Cast(o)                  % Cast to a State Space System   
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
