function G = tffnew(num,den,char,Ts,arg5)
%
% TFFNEW  Construction of a transfer function.
%
%	     Gs = tffnew([b2, b1, b0], [a3 a2 a1 a0])
%	     Gs = tffnew([b2, b1, b0], [a3 a2 a1 a0],'s')
%	     Gs = tffnew([b2, b1, b0], [a3 a2 a1 a0],'s',0)
%	     Hz = tffnew([b2, b1, b0], [a3 a2 a1 a0],'z',Ts)
%	     Gq = tffnew([b2, b1, b0], [a3 a2 a1 a0],'q',Ts)
%
%            Gs = tffnew             % same as Gs = tffnew([1],[1])
%            Gs = tffnew([b2 b1 b0]) % same as Gs = tffnew([b2 b1 b0],[1])
%
%	     Gs = tffnew(A,b,c,d)
%	     Hz = tffnew(Phi,H,c,d,Ts)
%
%            Gs = tffnew(Gs)         % copy constructor
%            Gz = tffnew(Gs,'z',Ts)  % casting copy constructor
%            Gq = tffnew(Gs,'q',Ts)  % casting copy constructor
%            Gs = tffnew(Gz,'s')     % casting copy constructor
%
%         The call
%
%	     G = tffnew([b3 b2, b1, b0], [a3 a2 a1 a0])
%
%	  constructs an s-kind transfer function of the form
%
%		       b3 s^3 + b2 s^2 + b1 s + b0
%	     G(s)  =  -----------------------------   .
%		       a3 s^3 + a2 s^2 + a1 s + a0
%
%	  Note that the coefficients are specified in decending
%	  order. The rational function will be hold by a matrix
%
%	     G = [ tag  b3   b2  b1  b0
%		   Ts	a3   a2  a1  a0
%		 ]
%
%	  where 'tag' is a magic tag of a DD object composed from the 
%         values 'tffclass' and 'kind' by invoking ddmagic(tffclass,kind).
%
%         The meanings of 'kind' are:
%
%	     kind = 1:	 G(s)   ... continuous system transfer function
%	     kind = 2:	 H(z)   ... discrete system transfer function
%	     kind = 3:	 G#(q)  ... q-domain description of discrete system
%
%	  'Ts' (sampling time)  represents a related sampling period which
%         has value 0 for continuous time transfer functions
%
%         Kind and sampling time may be specified by additional arguments:
%
%	  In addition it  is possible to calculate the	transfer function
%	  from a state space  representation [A,b,c,d]. This mode will be
%	  choosen if four arguments are passed and the third argument is 
%         no string argument. 
%
%            G = tffnew(A,b,c,d).
%
%         If in addition a fifth argument denoting a sampling period is 
%         passed,
%
%            Hz = tffnew(Phi,H,c,d,Ts)
%
%	  first four arguments are interpreted as the  state space repre-
%	  sentation of a discrete time dynamic system whith sampling period
%         Ts. The result is a z domain transfer function.
%
%    Linear Factors and Quadratic Factors
%
%       Gs = trf(V,{2,[5,0.7]},{0,0,[3,0.2]})
%                     
%                       (1 + s/2) * [1 + 2*0.7*s/5 + s^2/5^2
%       => G(s) = V * ----------------------------------------
%                          s^2 * [1 + 2*0.2*s/3 + s^2/3^2]
%
%                                           1
%       Gs = trf(1,{},{2})  =>  G(s) = -----------
%                                        1 + s/2
%
%                                             1 + s/5
%       Gs = trf(3,{5},{0})  =>  G(s) = 3 * -----------
%                                                s
%
%    See Also: tfflf, tffqf, tffmul, tffdiv, tffadd, tffcmp
%

   if ( nargin == 0 )
      G = tffnew(1,1);
      return
   end

   if ( nargin == 1 )  % simple copy constructor
      [class,kind,sign] = ddmagic(num);
      if ( class == tffclass )
         G = num;
         if ( sign < 0 )
            G(1) = -G(1);  G(2,:) = -G(2,:);
         end
         return;
      elseif ( class == 0 )
         G = tffnew(num,1);
         return
      else
         cname = ddclass(class);
         eval(['G=tff',cname,'(num);']);
         %error('Cannot construct transfer function from');
         return;
      end
   end


      % handle short forms tffnew('z',Ts) and tffnew('q',Ts)

   if ( nargin == 2 )
      if ( isstr(num) )
         G = tffnew(1,1,num,den);
         return
      end
   end

      % handle casting copy constructor if 2nd argument is a string


   if ( nargin >= 2 )
      if ( isstr(den) )
         numden = tffnew(num);  numden(:,1) = [];
         if ( nargin == 2 )
            G = tffnew(numden(1,:),numden(2,:),den);         
         elseif ( nargin == 3 )
            if isdouble(num) && iscell(den) && iscell(char)
               G = tfffac(num,den,char);
            else
               G = tffnew(numden(1,:),numden(2,:),den,char);         
            end
         else
            error('bad argument list')
         end
         return
      end
   end


      % set defaults for kind and Ts ...


   if ( nargin < 3 ) kind = 1; end
   if ( nargin < 4 ) Ts = 0;   end


      % ... and prepare for actual construction


   if ( nargin >= 3 )
      if ( ~isstr(char) & (nargin == 4 | nargin == 5 ) )
         A = num;  b = den;  c = char;  d = Ts;
         [num,den] = ss2tf(A,b,c,d,1);
         G = tffcan(tffnew(num,den));
         if ( nargin == 5 )
	    G(1) = ddmagic(tffclass,2);  G(2) = arg5;
         end
         return
      else
         if ( strcmp(char,'s') )
            kind = 1;
         elseif ( strcmp(char,'z') )
            kind = 2;
         elseif ( strcmp(char,'q') )
            kind = 3;
         elseif (nargin == 3 && isa(num,'double') && iscell(den) && iscell(char))
            G = tfffac(num,den,char);
            return
         else
            error(['bad kind specified for transfer function: ',char]);
         end
      end
   end

   if ( kind == 1 & Ts ~= 0 )
      error('Sampling time must be 0 for s-kind transfer functions')
   end

   if ( kind > 1 & Ts == 0 )
      error(['Sampling time (> 0) must be specified for ',char,...
             '-kind transfer function'])
   end

   deg_num = max(size(num)) - 1;
   deg_den = max(size(den)) - 1;
   deg = max(deg_num,deg_den);

   m = deg+2;
   G = zeros(2,m);

   G(1) = ddmagic(tffclass,kind);		  % continuos system tff
   G(2) = Ts;

   deg_num = max(deg_num,0);	   % ( HtZ 16-Jan-91 )
   deg_den = max(deg_den,0);

   G(1,m-deg_num:m) = num(:)';
   G(2,m-deg_den:m) = den(:)';

% eof
