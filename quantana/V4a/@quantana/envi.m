function obj = envi(obj,kind,varargin)
%
% ENVI   Setup an environment for a quantum particles (quons). 
%
%           obj = envi(quantana,kind);
%           obj = envi(quantana,kind,'par1',value1,'par2',value2,...)
%
%        Kind might be of the following values
%           'box'        particle in a box
%           'well'       particle in a potential well
%           'harmonic'   harmonic oscillator
%           'delta'      Delta wall
%           'qbit'       Qbit (only spin)
%        
%        Example 1: box with width L
%
%           eob = envi(quantana);         % same as envi(quantana,'box');
%           eob = envi(quantana,'box');
%           eob = envi(quantana,'box','z',-5:0.1:5,'L',10);
%
%        Example 2: harmonic oscillator with given omega
%
%           eob = envi(quantana,'harmonic');
%           eob = envi(quantana,'harmonic','z',-5:0.1:5,'omega',2);
%
   if (nargin < 2)
      kind = 'box';  varargin = {};
   end
   
   if (rem(length(varargin),2) ~= 0)
      error('even number of arguments expected!');
   end
   
   j = 1;
   while (j <= length(varargin))
      name = varargin{j};
      if (~isstr(name))
         name, error(sprintf('string expected for arg%d!',j));
      end
      j = j+2;
   end
   
   obj = setvlist(obj,varargin);  % set all parameters of argument list
   
      % common parameter setup
      
   obj = set(obj,'hbar',1);                  % default hbar
   obj = set(obj,'m',1);                     % default mass
   obj = set(obj,'zspace',-5:0.1:5);         % default zspace
   obj = set(obj,'kind',kind);               % default kind
   obj = set(obj,'nmax',20);                 % default nmax
   obj = set(obj,'nmin',0);                  % default nmin
   obj = set(obj,'dwell',[]);                % default dwell time
   obj = set(obj,'trans',[]);                % default transition time
   obj = set(obj,'colors',[]);               % default colors
   
      % let's go ...
      
   switch kind
      case 'box'
         obj = set(obj,'zspace',-5:0.1:5);  % default zspace
         obj = set(obj,'L',10);             % default width of box
         obj = setvlist(obj,varargin);      % overwrite settings with args
         obj = set(obj,'title',sprintf('box@%g',get(obj,'L')));
      case 'well'
         obj = setvlist(obj,varargin);      % overwrite settings with args
      case 'harmonic'
         obj = set(obj,'omega',1);          % default oscillator frequency
         obj = setvlist(obj,varargin);      % overwrite settings with args
         obj = set(obj,'title',sprintf('harmonic@%g',get(obj,'omega')));
      case 'delta'
         obj = set(obj,'alfa',1);           % default height of dirac pulse
         obj = setvlist(obj,varargin);      % overwrite settings with args
      case 'qbit'
         obj = setvlist(obj,varargin);      % overwrite settings with args
      otherwise
         kind, error('unknown kind!');
   end
   
   return
   
%==========================================================================

function obj = setvlist(obj,vlist)
%
   if (length(vlist) > 0)
      obj = set(obj,vlist);
   end
   return
   
%eof   
      
%eof   
         