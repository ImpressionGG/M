function out = harmonic(varargin)
% 
% HARMONIC Harmonic Oscillator
%          Create a HARMONIC object as a derived QUANTANA object of kind PLAY.
%
%              harmonic                       % open demo
%
%              obj = harmonic;                % default constructor
%
%              obj = harmonic(hbar*omega)              % set hbar * omega
%              obj = harmonic(hbar*omega,-10:0.1:10);  % set also zspace
%
%              obj = harmonic(format,par,dat) % general form of constructor
%
%          Methods:
%
%             - demo            open demo menu
%             - eig             eigen functions and eigen values
%             - harmonic        constructor
%             - potential       return potential function values
%             - setup           setup precalculated eigenfunctions
%             - zspace          retrieve z-vector of z-space
%
%          See also SHELL, QUANTANA, HARMONIC/DEMO
%   
   varargin = varargfix(varargin);

      % set argument defaults

   fmt = '';  par = [];
   dat.hbar = 1;  dat.omega = 1;  dat.zspace = -10:0.1:10; dat.m = 1; 

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
      fmt = varargin{1};  par = varargin{2};  dat = varargin{3};
   else
      error('1, 2 or 3 args expected!');
   end

      % check arguments

   if (~isa(dat.hbar,'double') || ~isa(dat.omega,'double'))
      error('hbar & omega must be double!');
   end

   if (~isa(dat.zspace,'double') || min(size(dat.zspace)) ~= 1)
      error('zspace must be a double vector!');
   end
   
      % object creation
      
   [obj,she] = derive(quantana(fmt,par,dat),mfilename);
   obj = class(obj,obj.tag,she);     

   if (nargout==0)
      demo(obj);
   else
      out = obj;
   end
   return           

% eof   