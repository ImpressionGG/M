function obj = ladder(eob,mode)
% 
% LADDER   Create a ladder operator object
%
%             eob = envi(quantana,'box');  % define environment (e.g.box)
%
%             oob = ladder(eob,+1);        % creation operator 
%             oob = ladder(eob,-1);        % anihilation operator 
%             oob = ladder(eob,0);         % creation & anihilation op. 
%
%          Environment parameters
%
%             colors:   color sequence                 (default 'rmvbgdno')
%             nmin:     minimum n for animation        (default 0)
%             nmax:     maximum n for animation        (default 3)
%             trans:    transition time                (default 5)
%             dwell:    dwell time between transitions (default 2)
%
%          Methods
%             progress      get progressing quantities
%
%          See also QUANTANA, ENVI, QUON
%   
   if (~isa(eob,'quantana'))
      error('quantana object (environment) expected for arg1');
   end

   if (nargin < 2)
      mode = 1;
   end
   
   if (~(mode == 1 || mode == -1 || mode == 0))
      error('mode (arg2) must be +1, 0 or -1!');
   end
   
      % set argument defaults

   fmt = '#LADDER';  par = get(eob);

   dat.kind = par.kind;              % quon kind
   dat.zspace = either(par.zspace(:),(-5:0.1:5)');  
   dat.colors = either(par.colors,'rmvbgdno');  
   dat.nmin = either(max(0,par.nmin),0);  
   dat.nmax = either(par.nmax,3);  
   dat.trans = either(par.trans,5);  
   dat.dwell = either(par.dwell,2);  
   dat.mode = mode;                  %  +1 or -1
   
      % check arguments

   if (~isa(dat.zspace,'double') || min(size(dat.zspace)) ~= 1)
      error('zspace must be a double vector!');
   end

      % data for sphere display
      
   [dat.sphx,dat.sphy,dat.sphz] = sphere(150);
   dat.opcre = smart(imread('image/opcre.jpg'));
   dat.opani = smart(imread('image/opani.jpg'));
   
      % object creation
      
   [obj,she] = derive(quantana(fmt,par,dat),mfilename);
   obj = class(obj,obj.tag,she);     

   if (mode == 1)
      obj = set(obj,'title','creation');
   else
      obj = set(obj,'title','anihilation');
   end
   return           

%==========================================================================

% eof