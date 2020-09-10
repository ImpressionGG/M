function out = quon(eob,psi,F)
% 
% QUON     Generic quantum object.
%          Create a QUON object as a derived QUANTANA object.
%
%             eob = envi(quantana,'box');  % define environment (e.g.box)
%
%             qob = quon(eob);             % psi according to lowest energy 
%             qob = quon(eob,1);           % particle in box in state 1
%
%             qob = quon(eob,psi);         % explicite psi (field = 0)
%             qob = quon(eob,psi,F);       % explicite psi & external field
%
%          Construction from basic data
%
%             qob = quon(fmt,par,dat)      % construct from basic data
%
%          eob parameters:
%             hbar:         reduced Planck number
%             m:            particle mass
%             nmax:         max number of expansion coefficients
%             zspace:       z-space
%
%          See also QUANTANA, ENVI, BION, EIG, WAVE
%   
   if (~isa(eob,'quantana') & nargin ~= 3)
      error('quantana object (environment) expected for arg1, or quon(fmt,par,dat)');
   end

   if (nargin < 2)
      psi = 1;
   end
   
   if (nargin < 3)
      F = 0;
   end

      % set argument defaults

   if (~isa(eob,'quantana'))            % construct from basic data
      fmt = eob;  par = psi;  dat = F;
      psi = dat.psi;  F = dat.F;
   else
      fmt = '#QUON';  par = get(eob);

      dat.kind = par.kind;              % quon kind
      dat.hbar = either(par.hbar,1);    % reduced Planck constant
      dat.nmax = either(par.nmax,20);   % max number of expansion coeffs
      dat.m = either(par.m,1);          % mass of particles
      dat.sigma = [];                   % std dev for gauss shape
      dat.center = [];                  % center for gauss shape
      dat.F = F;                        % external field

      dat.zspace = either(par.zspace(:),(-5:0.1:5)');  

      dat.Psi = [];      % precalculated eigen functions
      dat.psi = [];      % actual psi function
      dat.energy = [];   % energy values 
      dat.basis = [];    % eigen function basis 
      dat.eco = [];      % actual expansion coefficients
   end
   
      % check arguments

   if (~isa(dat.hbar,'double'))
      error('hbar must be double!');
   end

   if (~isa(dat.zspace,'double') || min(size(dat.zspace)) ~= 1)
      error('zspace must be a double vector!');
   end
   
      % object creation
      
   [obj,she] = derive(quantana(fmt,par,dat),mfilename);
   obj = class(obj,obj.tag,she);     

      % set psi & map
   
   z = dat.zspace;
   if (length(psi) < length(z))
      idx = psi;                     % mode indices
      psi = eig(obj,idx);            % ground state of particle
      if (length(idx) <= 1)
         psi = normalize(psi,z);
      else
         psi = normalize(sum(psi')',z);
      end
   end
   
      % normalize wave function
      
   z = dat.zspace;
   dat.psi = normalize(psi,z);       % normalize wave function
   
   if(~isempty(dat.psi))
      if (length(dat.psi) ~= length(dat.zspace))
         error('dimensions of z and psi must match!');
      end
      
      N = length(dat.zspace);
      [Psi,En] = eig(obj,1:min(N,dat.nmax+1));
            
         % calculate map transformation matrix, which allows to
         % expand the wave function and calculate expansion coefficients
         % (eco), i.e. psi = map*eco. eco is a coefficient vector for an
         % expansion in the eigen states (therefore not normalized). To
         % transform back we have to calculate: psi = map*eco
      
      dat.Psi = Psi;
      dat.map = gramschmidt(obj,Psi);
      dat.eco = dat.map' * dat.psi;   % phi is a coefficient vector
      dat.energy = En;           
   end
   
   obj = data(obj,dat);               % refresh data
   
      % Finish
      
   if (nargout==0)
      demo(obj);
   else
      out = obj;
   end
   return           

%==========================================================================

% eof