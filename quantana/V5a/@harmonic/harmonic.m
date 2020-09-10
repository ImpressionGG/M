classdef harmonic < quantana           % Harmonic Class Definition
%
%%%function out = harmonic(varargin)
% 
% HARMONIC Harmonic Object constructor
%          Create a HARMONIC object as a derived QUANTANA object of kind PLAY.
%          
%              osc = harmonic;                       % default constructor
%
%              osc = harmonic(hbar*omega)            % set hbar * omega
%              osc = harmonic(hbar*omega,-5:0.1:5);  % set also zspace
%              osc = harmonic(hbar*omega,z,psi);     % set also psi
%
%              osc = harmonic(format,par,dat) % general form of constructor
%
%          External Field
%
%              osc = harmonic([hbar*omega,F])            % set hbar * omega
%              osc = harmonic([hbar*omega,F],-5:0.1:5);  % set also zspace
%              osc = harmonic([hbar*omega,F],z,psi);     % set also psi
%
%          Another easy way to update psi and F
%
%              osc = harmonic(osc,psi,F);             % Update psi & F
%
%          Defaults:
%              omega = 1, hbar = 1, zspace = -5:0.1:5
%
%          Methods:
%
%             - demo            open demo menu
%             - eig             eigen functions and eigen values
%             - harmonic        constructor
%             - potential       return potential function values
%             - pseudo          create pseudo oscillator
%             - setup           setup precalculated eigenfunctions
%             - wave            calculate wave function at time t
%             - zspace          retrieve z-vector of z-space
%
%          See also SHELL, QUANTANA, HARMONIC/DEMO
%   
   methods                             % public methods                
      function o = harmonic(varargin)  % quantana constructor  
         varargin = Varargfix(varargin);

            % set argument defaults

         fmt = '';  par = [];
         dat.hbar = 1;  dat.omega = 1;  dat.F = 0;  dat.m = 1;
         dat.zspace = -5:0.1:5; 
         dat.psi = [];  dat.map = [];  dat.energy = [];  dat.pseudo = 1;

            % process input arguments

         if (isempty(varargin))
            fmt = '#1.0';
         elseif (length(varargin) == 1)
            dat.hbar = 1;  dat.omega = varargin{1};
            fmt = sprintf('#%3.1f',dat.hbar*dat.omega);
         elseif (length(varargin) == 2)
            dat.hbar = 1;  dat.omega = varargin{1};  dat.zspace = varargin{2};
            fmt = sprintf('#%3.1f',dat.hbar*dat.omega);
         elseif (length(varargin) == 3)
            if (isa(varargin{1},'harmonic'))   % then update psi & F
               fmt = format(varargin{1});  dat = data(varargin{1});  
               par = get(varargin{1});  dat.psi = varargin{2};  dat.F = varargin{3};
               par.psi = [];  % must reset pre-calculated psi values
            elseif (isstruct(varargin{2}) | isempty(varargin{2}))   % then enter also psi
               fmt = varargin{1};  par = varargin{2};  dat = varargin{3};
            else
               dat.hbar = 1;  dat.omega = varargin{1};  
               dat.zspace = varargin{2};  dat.psi = varargin{3};
               fmt = sprintf('#%3.1f',dat.hbar*dat.omega);
            end
         else
            error('1, 2 or 3 args expected!');
         end

            % post processing

         dat.zspace = dat.zspace(:);
         if (length(dat.omega)>1) 
            dat.F = dat.omega(2);  dat.omega = dat.omega(1);
         end

            % check arguments

         if (~isa(dat.hbar,'double') || ~isa(dat.omega,'double'))
            error('hbar & omega must be double!');
         end

         if (~isa(dat.zspace,'double') || min(size(dat.zspace)) ~= 1)
            error('zspace must be a double vector!');
         end

            % object creation

         %[obj,she] = derive(quantana(fmt,par,dat),mfilename);
         %obj = class(obj,obj.tag,she);
         par.format = fmt;
         o.tag = mfilename;
         o.type = 'play';
         o.par = par;
         o.data = dat;

            % Set psi & map

         if (isempty(dat.psi))
            dat.psi = eig(o,0);        % ground state of harmonic osc.
         end

         if(~isempty(dat.psi))
            dat.psi = quantana.normalize(dat.psi(:));
            if (length(dat.psi) ~= length(dat.zspace))
               error('dimensions of z and psi must match!');
            end

            N = length(dat.zspace);
            [o,Psi,En] = setup(o,min(N-1,20));  % pre-calculate eigen functions

               % calculate map transformation matrix
               % IDFT matrix is called 'map', i.e. psi = map*phi
               % phi is a coefficient vector for an expansion in the 
               % eigen states (therefore not normalized). To transform
               % back we have to calculate: psi = map*phi

            %dat.map = normalize(Psi);
            dat.map = gramschmidt(Psi);
            dat.phi = dat.map' * dat.psi;   % phi is a coefficient vector
            dat.energy = En;           
         end

         o.data = dat;                      % refresh data
      end
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function U = gramschmidt(X)
%
% GRAMSCHMIDT   Gram-Schmidt procedure to calculate an orthonormal 
%               basis according to a give set X of linear independent
%               basis vectors
%
   n = size(X,2);
   
   if (rank(X) ~= min(size(X)))
      error('rank deficite!');
   end
   
   for (j=1:n)
      xj = X(:,j);
      vj = xj;
      for (k=1:j-1)
         vj = vj - U(:,k) * U(:,k)'*xj;
      end
      uj = vj / sqrt((vj'*vj));    % normalize
      U(:,j) = uj;           % store in a matrix U = [u1,u2,...,uj]
   end
end
function varargs = Varargfix(varargs)
%
% VARARGFIX  Fix vararg list if nest level of vararg list is to deep
%            caused by subsequent class inheritance in class constructors.
%
%               vargs = varargfix(vargs);
%
%            See also: SMART, SHELL, CHAMELEON
%
   if (length(varargs) == 1)     % check calling convenience
      if (iscell(varargs{1}))    % for handing over varargin list
         varargs = varargs{1};   % remove one level!
      end
   end
end