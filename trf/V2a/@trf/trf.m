classdef trf < cordoba                 % TRF Class Definition
   methods                             % public methods                
      function o = trf(arg1,arg2,arg3,arg4)  % TRF constructor  
      %
      % TRF      Transfer function as a derived shell object
      %
      %              Gs = trf;                      % generic constructor
      %              Gs = trf(num,den);
      %
      % 	     Gs = trf([b2, b1, b0], [a3 a2 a1 a0])
      % 	     Gs = trf([b2, b1, b0], [a3 a2 a1 a0],'s')
      % 	     Gs = trf([b2, b1, b0], [a3 a2 a1 a0],'s',0)
      % 	     Hz = trf([b2, b1, b0], [a3 a2 a1 a0],'z',Ts)
      % 	     Gq = trf([b2, b1, b0], [a3 a2 a1 a0],'q',Ts)
      % 
      %            Gs = trf             % same as Gs = tffnew([1],[1])
      %            Gs = trf([b2 b1 b0]) % same as Gs = tffnew([b2 b1 b0],[1])
      % 
      % 	     Gs = trf(A,b,c,d)
      % 	     Hz = trf(Phi,H,c,d,Ts)
      % 
      %            Gs = trf(Gs)         % copy constructor
      %            Gz = trf(Gs,'z',Ts)  % casting copy constructor
      %            Gq = trf(Gs,'q',Ts)  % casting copy constructor
      %            Gs = trf(Gz,'s')     % casting copy constructor
      % 
      %       The call
      % 
      %   	     G = trf([b3 b2, b1, b0], [a3 a2 a1 a0])
      % 
      %  	  constructs an s-kind transfer function of the form
      % 
      %      	    	      b3 s^3 + b2 s^2 + b1 s + b0
      % 	        G(s)  =  -----------------------------   .
      %        		      a3 s^3 + a2 s^2 + a1 s + a0
      % 
      % 	  Note that the coefficients are specified in decending
      % 	  order. The rational function will be hold by a matrix
      % 
      % 	     data(G) = [ tag  b3   b2  b1  b0
      %      		        Ts	 a3   a2  a1  a0
      %                 ]
      % 
      % 	  where 'tag' is a magic tag of a DD object composed from the 
      %          values 'tffclass' and 'kind' by invoking ddmagic(tffclass,kind).
      % 
      %          The meanings of 'kind' are:
      % 
      % 	     kind = 1:	 G(s)   ... continuous system transfer function
      % 	     kind = 2:	 H(z)   ... discrete system transfer function
      % 	     kind = 3:	 G#(q)  ... q-domain description of discrete system
      % 
      % 	  'Ts' (sampling time)  represents a related sampling period which
      %          has value 0 for continuous time transfer functions
      % 
      %          Kind and sampling time may be specified by additional arguments:
      % 
      % 	  In addition it  is possible to calculate the	transfer function
      % 	  from a state space  representation [A,b,c,d]. This mode will be
      % 	  choosen if four arguments are passed and the third argument is 
      %    no string argument. 
      % 
      %       G = trf(A,b,c,d).
      % 
      %    If in addition a fifth argument denoting a sampling period is 
      %    passed,
      % 
      %       Hz = trf(Phi,H,c,d,Ts)
      % 
      % 	  first four arguments are interpreted as the  state space repre-
      % 	  sentation of a discrete time dynamic system whith sampling period
      %    Ts. The result is a z domain transfer function.
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
      %    Methods:
      %       bode          % draw bode plot
      %       can           % cancel transfer function
      %       cut           % cut-off frequency 
      %       dsp           % display transfer function
      %       fqr           % frequency response
      %       gain          % gain factor
      %       kind          % return kind of transfer function
      %       lf            % linear factor
      %       loop          % loop transfer function
      %       menu          % open TRF menu
      %       minus         % overloaded operator minus          
      %       mtimes        % overloaded operator times          
      %       mrdivide      % overloaded operator divide          
      %       plus          % overloaded operator plus  
      %       rloc          % root locus plot
      %       qf            % quadratic factor
      %       qtf           % q-transformation
      %       rsp           % response of a transfer function
      %       ssr           % state space representation
      %       step          % plot step response function
      %       stf           % s-transformation
      %       trim          % trim transfer function
      %       wtf           % w-transformation
      %       ztf           % z-transformation
      %
      %          See also SHELL 
      %
         if (nargin == 0)
            arg = 'strf';              % 'shell' type by default
         end
         
         o@cordoba('strf');            % construct base object
         o.tag = mfilename;            % tag must equal derived class name

         if (nargin == 1 && (isstruct(arg1) || isa(arg1,'trf')))
            o.type = arg1.type;        % cast from corazon object
            o.par = arg1.par;          % cast from corazon object
            o.data = arg1.data;        % cast from corazon object
            o.work = arg1.work;        % cast from corazon object
            return                     % construction from bag
         end
         
         if (nargin == 0)
            % G = tffnew;
            o.type = 'shell';
            return                     % return with generic constructor
         elseif (nargin == 1) && isa(arg1,'char')
            o.type = arg1;
            return
%        elseif (nargin == 1) && isa(arg1,'corazon')
%           o.par = arg1.par;          % cast from corazon object
%           o.data = arg1.data;        % cast from corazon object
%           o.work = arg1.work;        % cast from corazon object
%           return
         elseif (nargin == 1) && isa(arg1,'corazon')
            oo = arg1;
            G = tffnew(var(oo,'num'),var(oo,'den'));
         elseif (nargin == 1)
            G = tffnew(arg1);
         elseif (nargin == 2)
            G = tffnew(arg1,arg2);
         elseif (nargin == 3)
            if (ischar(arg2))
               arg1 = data(arg1);   % casting operation, e.g. Gq = trf(Gs,'q',Ts)
            end
            G = tffnew(arg1,arg2,arg3);
         elseif (nargin == 4)
            G = tffnew(arg1,arg2,arg3,arg4);
         elseif (nargin == 5)
            G = tffnew(arg1,arg2,arg3,arg4,arg5);
         else
            error('max 5 args expected!');
         end

         [clas,kind] = ddmagic(G);
         fmts = {'(s)','(z)','(q)'};

         fmt = fmts{kind};
         o.type = [fmt(2),'trf'];          
         o.par = [];
         o.par.format = fmt(2);
         o.par.init = '';
         
         o = launch(o,'shell');        % provide launch function
         o.data = G;
      end
   end
   methods (Static)
      o = lf(omega)                    % linear factor
      o = qf(omega,zeta)               % quadratic factor
      out = gao(varargin)              % get axis object
   end   
end
