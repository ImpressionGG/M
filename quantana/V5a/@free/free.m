function out = free(varargin)
% 
% FREE     Free Particle:  Create a FREE particle object as a derived
%          QUANTANA object of kind PLAY.
%
%              free                           % open demo
%
%              obj = free(-5:0.1:5,k);        % constructor with zspace def
%              obj = free(-5:0.1:5);          % constructor with zspace def
%              obj = free;                    % zspace = -5:0.1:5
%
%              obj = gauss(free,sigma,center) % gaussian wave packet
%              obj = gauss(free,0.5,2)        % gaussian wave packet
%
%              obj = free(format,par,dat)     % general form of constructor
%
%          Methods:
%
%             - demo            open demo menu
%             - eig             eigen functions and eigen values
%             - free            constructor
%             - gauss           convert to gaussian wave
%             - kspace          return k values according to DFT
%             - scattering      create forward & backward scattering objs
%             - zspace          retrieve z-vector of z-space
%
%          See also SHELL, QUANTANA, FREE/DEMO, FREE/EIG, FREE/ZSPACE
%                   FREE/GAUSS, FREE/SCATTER
%   
   varargin = varargfix(varargin);

      % set argument defaults

   fmt = 'generic';  par = [];
   dat.hbar = 1;  dat.m = 1;     % reduced Planck constant & mass
   dat.sigma = NaN;
   dat.center = NaN;
   
   k = [];
   
      % process input arguments

   if (isempty(varargin))
      z = (-5:0.1:5)'; 
      lambda = z(end)-z(1);  k = 2*pi/lambda;
      dat.psi = exp(i*k*z);  dat.k = k;
      dat.zspace = z;
   elseif (length(varargin) == 1)
      z = varargin{1};  z = z(:);
      lambda = z(end)-z(1);  k = 2*pi/lambda;
      dat.psi = exp(i*k*z);  dat.k = k;
      dat.zspace = z;  z = z(:);
   elseif (length(varargin) == 2)
      z = varargin{1};  z = z(:);
      lambda = z(end)-z(1);
      kappa = varargin{2}; k = kappa * 2*pi/lambda;
      dat.psi = exp(i*k*z);  dat.k = k;
      dat.zspace = z(:);
   elseif (length(varargin) == 3)
      fmt = varargin{1};  par = varargin{2};  dat = varargin{3};
   else
      error('0, 1 or 3 args expected!');
   end

   
      % check arguments

   if (~isa(dat.zspace,'double') || min(size(dat.zspace)) ~= 1)
      error('zspace must be a double vector!');
   end

   if (length(dat.zspace) ~= length(dat.psi))
      error('dimensions of wave function and zspace must match!');
   end
   
      % calculate DFT and store IDFT transformatiion matrices
      % IDFT matrix is called 'map', i.e. psi = map*phi
      
   [dat.phi,T] = dft(quantana,dat.psi);   
   dat.map = T'/length(dat.psi);           
    
      % object creation
      
   [obj,she] = derive(quantana(fmt,par,dat),mfilename);
   obj = class(obj,obj.tag,she);     

   if (~isempty(k))
      obj = set(obj,'title',sprintf('k=%g',k));
   end
   
   if (nargout==0)
      demo(obj);
   else
      out = obj;
   end
   return           

% eof   