function oo = filter(o,varargin)       % Filter Composition, Filtering 
%
% FILTER   Filter a data stream
%
%             yf = filter(o,y,t)
%
%          Options:
%             o = opt(o,'type','LowPass2')  % filter type
%             o = opt(o,'bandwidth',f)      % filter bandwidth [Hz]
%             o = opt(o,'zeta',0.6)         % filter damping
%             o = opt(o,'kind',1)           % kind of filtering
%
%          kind=0 means simple forwards filtering, kind=2 forces fore/back
%          filtering, and kind=3 performs highpass filtering with subse-
%          quent fore/back low pass filtering.
%
%          Filter Types:
%             'order2':   order 2 filter
%
%          Filter composition: return system matrices A,B,C,D in 
%          var(oo,'A'), var(oo,'B'), var(oo,'C') and var(oo,'D'),
%          and numerator/denominator in var(oo,'num'), var(oo,'den').
%
%             oo = filter(with(sho,'filter'))
%
%             oo = filter(o,'LowPass2')
%             oo = filter(o,'HighPass2')
%             oo = filter(o,'LowPass4')
%             oo = filter(o,'HighPass4')
%             oo = filter(o,'Integrator')
%
%          Note: the result can be easily converted to a transfer
%          function class object by calling oo = trf(oo).
%
%             Copyright(c): Bluenetics 2020 
%
%          See also: CORAZON, COOK, TRF
%
   [gamma,o] = manage(o,varargin,@Filter,@LowPass2,@HighPass2,...
                                 @LowPass4,@HighPass4,@Integrator);
   oo = gamma(o);                   % invoke local function
end

%==========================================================================
% Filtering
%==========================================================================

function y = Filter(o)                 % Default Filter Function       
%
   u = arg(o,1);
   t = arg(o,2);

   if isempty(var(o,'A'));
      type = opt(o,{'type','LowPass2'});
      oo = filter(o,type);
   else
      oo = o;
   end
   
      % if both u (arg2) and t (arg3) are empty then we just return
      % the filter object
      
   if isempty(u) && isempty(t)
      y = oo;
      return
   end
   
      % otherwise dispatch method
      
   method = opt(o,{'method',0});
   switch method
      case 0
         y = Respond(oo,u,t);
      case 1
         y1 = u(1) + Respond(oo,u-u(1),t);
         v = u(end:-1:1);              % reversed u
         y2 = v(1) + Respond(oo,v-v(1),t);
         y = [y1 + y2(end:-1:1)] / 2;  % average fore/back responses
      case 2
         y1 = u(1) + Respond(oo,u-u(1),t);
         v = u(end:-1:1);              % reversed u
         y2 = v(1) + Respond(oo,v-v(1),t);
         y = [y1 + y2(end:-1:1)] / 2;  % average fore/back responses
   end
end
function y = Respond(o,u,t)            % Calculate Filter Response     
   A = var(o,'A');
   B = var(o,'B');
   C = var(o,'C');
   D = var(o,'D');
   
   Ts = (t(end)-t(1)) / (length(t)-1); % sampling interval
   [Phi,H] = C2D(A,B,Ts);
   
      % average u(k) with u(k+1), at the end extrapolate assuming
      % same slope: u(end+1) = u(end) + [u(end)-u(end-1)]
      
   u = u(:);  u(end+1) = 2*u(end) - u(end-1);
   u = (u(1:end-1) + u(2:end)) / 2;
   
      % efficiently run difference equation using LTITR()
      
   x0 = 0*A(:,1);                      % initial state
   x = ltitr(Phi,H,u,x0)';          % discrete system response
   y = C*x + D*u';
end
function [Phi,H] = C2D(A,B,Ts)         % Continuos->Discrete Conversion
   [m,n] = size(A);
   [m,nb] = size(B);
   
   S = expm([[A B]*Ts; zeros(nb,n+nb)]);
   Phi = S(1:n,1:n);
   H = S(1:n,n+1:n+nb);
end

%==========================================================================
% Order 2 Low Pass & High Pass
%==========================================================================

function oo = LowPass2(o,omega,zeta)   % Order 2 Low Pass              
%
% LOWPASS2   Get system matrices of order 2 low pass filter with transfer
%            function
%
%                                        1
%               G(s) = --------------------------------------
%                         s^2/omega^2 + 2*zeta*s/omega + 1 
%
%            Syntax:
%
%               oo = LowPass2(o,omega,zeta)
%               oo = LowPass2(o,omega)          % zeta = 0.6
%
%            Return system matrices A,B,C,D in var(oo,'A'), var(oo,'B'),
%            var(oo,'C') and var(oo,'D'). Return denominator and numerator
%            polynomial coefficients in var(oo,'num') and var(oo,'den')
%
   if (nargin < 2)
      f = opt(o,{'bandwidth',1/(2*pi)});
      omega = 2*pi*f;
   end
   if (nargin < 3)
      zeta = opt(o,{'zeta',0.6});
   end
   oo = Model(o,1,[1/omega^2,2*zeta/omega,1]);
end
function oo = HighPass2(o,omega,zeta)  % Order 2 High Pass             
%
% HIGHPASS2  Get system matrices of order 2 high pass filter with transfer
%            function
%
%                                     s^2/omega^2
%               G(s) = --------------------------------------
%                         s^2/omega^2 + 2*zeta*s/omega + 1 
%
%            Syntax:
%
%               oo = LowPass2(o,omega,zeta)
%               oo = LowPass2(o,omega)          % zeta = 0.6
%
%            Return system matrices A,B,C,D in var(oo,'A'), var(oo,'B'),
%            var(oo,'C') and var(oo,'D'). Return denominator and numerator
%            polynomial coefficients in var(oo,'num') and var(oo,'den')
%
   if (nargin < 2)
      f = opt(o,{'bandwidth',1/(2*pi)});
      omega = 2*pi*f;
   end
   if (nargin < 3)
      zeta = opt(o,{'zeta',0.6});
   end
   oo = Model(o,[1/omega^2 0 0],[1/omega^2,2*zeta/omega,1]);
end

%==========================================================================
% Order 4 Low Pass & High Pass
%==========================================================================

function oo = LowPass4(o,omega,zeta)   % Order 4 Low Pass              
%
% LOWPASS4   Get system matrices of order 4 low pass filter with transfer
%            function
%
%                                        1
%               G(s) = --------------------------------------
%                       (s^2/omega^2 + 2*zeta*s/omega + 1)^2 
%
%            Syntax:
%
%               oo = LowPass4(o,omega,zeta)
%               oo = LowPass4(o,omega)          % zeta = 0.6
%
%            Return system matrices A,B,C,D in var(oo,'A'), var(oo,'B'),
%            var(oo,'C') and var(oo,'D'). Return denominator and numerator
%            polynomial coefficients in var(oo,'num') and var(oo,'den')
%
   if (nargin < 2)
      f = opt(o,{'bandwidth',1/(2*pi)});
      omega = 2*pi*f;
   end
   if (nargin < 3)
      zeta = opt(o,{'zeta',0.6});
   end
   den = [1/omega^2,2*zeta/omega,1]; 
   oo = Model(o,1,conv(den,den));
end
function oo = HighPass4(o,omega,zeta)  % Order 4 High Pass             
%
% HIGHPASS4  Get system matrices of order 4 high pass filter with transfer
%            function
%
%                                       s^4/omega^4
%               G(s) = ----------------------------------------
%                         (s^2/omega^2 + 2*zeta*s/omega + 1)^2 
%
%            Syntax:
%
%               oo = HighPass4(o,omega,zeta)
%               oo = HighPass4(o,omega)          % zeta = 0.6
%
%            Return system matrices A,B,C,D in var(oo,'A'), var(oo,'B'),
%            var(oo,'C') and var(oo,'D'). Return denominator and numerator
%            polynomial coefficients in var(oo,'num') and var(oo,'den')
%
   if (nargin < 2)
      f = opt(o,{'bandwidth',1/(2*pi)});
      omega = 2*pi*f;
   end
   if (nargin < 3)
      zeta = opt(o,{'zeta',0.6});
   end
   num = [1/omega^2 0 0];
   den = [1/omega^2,2*zeta/omega,1]; 
   oo = Model(o,conv(num,num),conv(den,den));
end

%==========================================================================
% Integrator
%==========================================================================

function oo = Integrator(o,omega,zeta)   % Integrator                  
%
% INTEGRATOR Get system matrices of integrator with transfer
%            function
%
%                         1
%               G(s) = -------
%                         s 
%
%            Syntax:
%
%               oo = Integrator(o)
%
%            Return system matrices A,B,C,D in var(oo,'A'), var(oo,'B'),
%            var(oo,'C') and var(oo,'D'). Return denominator and numerator
%            polynomial coefficients in var(oo,'num') and var(oo,'den')
%
   oo = Model(o,1,[1 0]);
end

%==========================================================================
% Standard Form
%==========================================================================

function [A,B,C,D] = Model(o,num,den)  % Standard State Model Matrices 
%
% STANDARD  Return system matrices A,B,C,D of standard form
%
%              [A,B,C,D] = Standard(o,num,den)
%              oo = Standard(o,num,den)
%
%           For a transfer function
%
%                                s + 2
%              G(s) = -----------------------------
%                         s^2/T^2 + 2*s/T  +  1
%
%           call
%
%              [A,B,C,D] = Standard(o,[1 2],[1/T^2 2/T 1])
%
%           Theory:
%
%                      [   0     1     0   ...    0   ]     [ 0 ]
%                      [   0     0     1   ...    0   ]     [ 0 ]
%              dx/dt = [   :     :     :   ...    0   ] x + [ 0 ] * u
%                      [   0     0     0   ...    1   ]     [ : ]
%                      [ -a(0) -a(1) -a(2) ... -a(n-1)]     [ 1 ]
%
%                 y  = [ b'(0) b'(1) b'(2) ... b'(n-1)] x +   D * u
%
%           Given a transfer function with normalized a(n) = 1
%                       
%                      b(n)s^n + b(n-1)*s^(n-1) + ... + b(1)*s + b(0)
%              G(s) = -----------------------------------------------
%                       1*s^n + a(n-1)*s^(n-1) + ... + a(1)*s + a(0)
%
%           convert using b'(k) = b(k) - b(n)*a(k)
%
%                            b'(n-1)s^(n-1) + ... + b'(1)*s + b'(0)
%              G(s) = b(n) + --------------------------------------
%                                   s^n + ... + a(1)*s + a(0)
%
   if (size(num,1) ~= 1 || size(den,1) ~= 1)
      error('num and den must be row vectors!')
   end
   if (length(den) <= 1)
      error('system order must be >= 1!');
   end
   if (length(num) > length(den))
      error('numerator must not be of higher order than denominator!');
   end

      % store numerator and denominator in object variables

   oo = var(o,'num',num);  oo = var(oo,'den',den);       % store

      % normalize numerator and denominator
      
   n = length(den) - 1;                % system order
   num = [zeros(1,length(den)-length(num)),num];
   num = num / den(1);  den = den / den(1);
   
      % system matrices
      
   if (n == 1)
      A = -den(2);
      B = 1;
      C = num(2) + A*num(1);
      D = num(1);
   else
      A = diag(ones(1,n-1),1);
      %A(n,:) = -den(2:end);
      A(n,:) = -den(end:-1:2);
      B = A(n-1,:)';
      C = num(end:-1:2) + A(n,:)*num(1);
      D = num(1);
   end
   
      % pack into variables
      
   if (nargout <= 1)
      oo = var(oo,'A',A);  oo = var(oo,'B',B);
      oo = var(oo,'C',C);  oo = var(oo,'D',D);
      A = oo;
   end
end
