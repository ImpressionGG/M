function oo = new(o,varargin)          % New Object Creation           
%
% NEW   Create new CORDOBA or derived CORDOBA object. Use options
%       'title' and 'comment' to provide title and comment, if required.
%
%       Package objects: 
%
%          oo = new(o,'Package','vib')     % oo.kind = 'vib'
%          oo = new(o,'Package')           % oo.kind = 'any' by default
%
%       Simple objects: containing x,y,th,ux and uy signals
%
%          oo = new(o,'Simple','xtype')    % oo.type = 'xtype'
%          oo = new(o,'Simple','smp')      % oo.type = 'smp'
%          oo = new(o,'Simple')            % oo.type = 'smp'
%
%       Plain objects: containing x,y and th signals
%
%          oo = new(o,'Plain','ytype')     % oo.type = 'ytype'
%          oo = new(o,'Plain','pln')       % oo.type = 'pln'
%          oo = new(o,'Plain')             % oo.type = 'pln'
%
%       Basis Objects
%
%          oo = new(o,'Basis','bmc')       % oo.type = 'bmc'
%          oo = new(o,'Basis','vuc')       % oo.type = 'vib'
%          oo = new(o,'Basis','vsc')       % oo.type = 'vib'
%
%          oo = new(o,'Bmc')               % oo.type = 'bmc'
%          oo = new(o,'Vuc')               % oo.type = 'vib'
%          oo = new(o,'Vsc')               % oo.type = 'vib'
%
%       New machine number
%
%          machine = new(o,'Machine')      % generate random m/c number
%
%       Configuration: the following types are supported for standard
%       configuration of plotting: pln, smp, bmc, vib 
%
%          oo = new(o,'Config')
%
%       Copyright(c): Bluenetics 2020 
%
%       See also: CORDOBA
%
   [gamma,oo] = manage(o,varargin,@Package,@Simple,@Plain,...
                @Basis,@Bmc,@Vuc,@Vsc,@Machine);
   oo = gamma(oo);
end

%==========================================================================
% New Package Object
%==========================================================================

function oo = Package(o)               % New Package Object             
%
% PACKAGE   Create a new package object. Allow user to enter package
%           default parameters, and to create an optional package folder.
%
   kind = o.either(arg(o,1),'any');    % get kind arg
   oo = cordoba('pkg');                % construct CORDOBA package object
   oo.data = [];                       % make a non-container object
   
      % prepare package default parameters

   name = o.capital(oo.type);          % object name
   [date,time] = o.now;
   machine = get(o,{'machine','95000000000'});
   project = get(o,{'project',''});
   run = get(o,{'run',0});             % running number
   package = sprintf('@%s.%g',machine(end-3:end),run);
   creator = user(o,'name');
  
   title = opt(o,{'title',['Package ',package]});
   comment = opt(o,{'comment',{'(package object)'}});
   
   oo = set(oo,'title',title);
   oo = set(oo,'comment',comment);
   oo = set(oo,'kind',kind);
   oo = set(oo,'date',date,'time',time);
   oo = set(oo,'machine',machine);
   oo = set(oo,'project',project);
   oo = set(oo,'package',package);
   oo = set(oo,'creator',creator);
   oo = set(oo,'version',version(oo));

   oo = subplot(oo,'color',[0.95 0.8 0.5]);
   
   oo = opt(oo,'caption',opt(o,'caption'));
   
   if opt(o,'plain')
      oo = dialog(oo,'Plain',kind);    % open dialog for new plain package
   else
      oo = dialog(oo,'Package',kind);  % open dialog for new package
   end
   
   if isempty(oo)
      return                           % dialog canceled
   end
   
   oo = launch(oo,launch(o));          % inherit launch function 
end

%==========================================================================
% New Simple Object
%==========================================================================

function oo = Simple(o)                % New Simple Object             
   iif = @carabull.iif;                % short hand
   
   typ = o.either(arg(o,1),'smp');     % get type arg
   name = o.capital(typ);              % object name

   m = 6;  n = 10;  r = 8;             % rows x columns x repeats
   t = 0:1000/(m*n*r-1):1000;          % crate a time vector
   sz = size(t);
   om = r*2*pi/max(t);                 % random circular frequency

   x = (1+3*rand)*sin(om*t)+0.2*randn(sz); % create an 'x' data vector
   y = (1+3*rand)*cos(om*t)+0.3*randn(sz); % create an 'y' data vector
   p = 7*x + 7*y + 0.9*randn(sz);      % create a 'th' vector
   ux = 0.11*randn(size(x));           % create 'ux' data vector
   uy = 0.09*randn(size(y));           % create 'uy' data vector

   x = 10 + x.*(1+0.2*t/max(t));       % biased & time variant
   y = 8 + y.*(1+0.2*t/max(t));        % biased & time variant
   p = 70 + p.*(1+0.2*t/max(t));       % biased & time variant

      % create a cordoba object with t,x,y,p, ux & uy

   oo = cordoba(typ);                  % construct CORDOBA object
   oo = trace(oo,t,'x',x,'y',y,'p',p,'ux',ux,'uy',uy); 

   oo = set(oo,'sizes',[m,n,r]);       % set data sizes
   oo = set(oo,'method','blrm');       % set processing method

      % provide system
   
   oo = set(oo,'system',iif(rand < 0.5,'L','R'));
   
      % provide title & comments for the caracook object

   [date,time] = o.now;
   comment = {'sin/cos data (random frequency & magnitude)',...
              ['Type: ',oo.type]};

   machine = get(o,{'machine','95000000000'});
   package = get(o,{'package',[]});
   project = get(o,{'project',''});
           
%  oo = set(oo,'title',[o.now(date,time),' Simple ',o.capital(o.tag)]);
   oo = set(oo,'title',['Simple ',o.capital(o.tag),' @ ',o.now]);
   oo = set(oo,'comment',comment);
   oo = set(oo,'date',date,'time',time);
   oo = set(oo,'machine',machine,'project',project,'package',package);
   oo = set(oo,'version',version(oo));
   
      % add also a parameter of structure type
      % (there is not much meaning behind)
      
   shape.kind = 'circle';
   shape.color.line = 'b';
   shape.color.fill = 'y';
   shape.width = 3;
   oo = set(oo,'shape',shape);
   
      % add also a (junk) cell array
      
   oo.par.junk = {[0 1.5],shape};
      % convert to proper object class & setup plot configuration
      
   oo.tag = o.tag;                     % inherit tag from parent
   oo = balance(oo);                   % balance object
%  oo = Config(oo);                    % setup plot configuration
end

%==========================================================================
% New Plain Object
%==========================================================================

function oo = Plain(o)                 % New Plain Object              
   typ = o.either(arg(o,1),'pln');     % get type arg
   name = o.capital(typ);              % object name
   
   m = 5;  n = 8;  r = 10;             % rows x columns x repeats
   t = 0:1000/(m*n*r-1):1000;          % create a time vector
   sz = size(t);
   om = r*2*pi/max(t);                 % random circular frequency
   
   machine = get(o,{'machine','95000000000'});
   package = get(o,{'package',[]});
   project = get(o,{'project',''});

   x = (2+3*rand)*sin(om*t)+0.2*randn(sz); % create an 'x' data vector
   y = (2+3*rand)*cos(om*t)+0.3*randn(sz); % create an 'y' data vector
   p = 5*x + 5*y + 0.7*randn(sz);      % create a 'th' vector

   x = x.*(1+0.2*t/max(t));            % time variant
   y = y.*(1+0.2*t/max(t));            % time variant
   p = p.*(1+0.2*t/max(t));            % time variant

      % make a cordoba object with t,x,y & p

   oo = cordoba(typ);                  % construct CORDOBA object
   oo = trace(oo,t,'x',x,'y',y,'p',p); % make a trace with t, x & y

   oo = set(oo,'sizes',[m,n,r]);       % set data sizes
   oo = set(oo,'method','blcs');       % set processing method

      % provide system
   
   oo = set(oo,'system',o.iif(rand < 0.5,'L','R'));

      % provide title & comments for the caracook object

   [date,time] = o.now;
   comment = {'sin/cos data (random frequency & magnitude)',...
              ['Type: ',oo.type]};

%  oo = set(oo,'title',[o.now(date,time),' Plain ',o.capital(o.tag)]);
   oo = set(oo,'title',['Plain ',o.capital(o.tag),' @ ',o.now]);
   oo = set(oo,'comment',comment);
   oo = set(oo,'date',date,'time',time);
   oo = set(oo,'machine',machine,'project',project,'package',package);

      % convert to proper object class & setup plot configuration
      
   oo.tag = o.tag;                     % inherit tag from parent
   oo = balance(oo);                   % balance object
   %oo = ConfigPlain(oo);              % setup plot configuration
end
function o = OldConfigPlain(o)         % Configure Plain Object        
   o = subplot(o,'layout',1);
   o = subplot(o,'color',[1 1 0.7]);

   o = category(o,1,[-5 5],[0 0],'�');      % category 1 for x,y
   o = category(o,2,[-50 50],[0 0],'m�');   % category 2 for p

   o = config(o,'x',{1,'r',1});
   o = config(o,'y',{1,'b',1});
   o = config(o,'p',{2,'g',2});
end

%==========================================================================
% New Basis Objects (BMC, VUC, VSC)
%==========================================================================

function oo = Bmc(o)                   % Create BMC Object             
   oo = Basis(o,'bmc');
end
function oo = Vuc(o)                   % Create VUC Object             
   oo = Basis(o,'vuc');
end
function oo = Vsc(o)                   % Create VSC Object             
   oo = Basis(o,'vsc');
end

function oo = Basis(o,typ)             % Create New BMC/VUC/VSC Object 
   if (nargin < 2)
      typ = arg(o,1);                  % fetch type arg
   end
   
   o = opt(o,{'plugin.basis.sigma'},0.2);
   o = opt(o,{'plugin.basis.drift'},1.5);
   o = opt(o,{'plugin.basis.jump'},0.2);
   o = opt(o,{'plugin.basis.gantry'},'L');
   
   o = with(o,'plugin.basis');
   drift = opt(o,{'drift',2});         % drift of vibration test
   jump = opt(o,{'jump',0.1});         % jump of vibration test
   sig = opt(o,{'sigma',0.2});         % sigma for x/y
   Sig = 10*sig;                       % sigma for theta

   m = 1;  n = 1; 
   r = o.assoc(typ,{{'bmc',80},302});
   sz = m*n*r;                         % size of data vector

   t = 1:m*n*r;                        % create a time vector
   x = sig*randn + sig*randn(1,sz);    % create an 'x' data vector
   y = sig*randn + sig*randn(1,sz);    % create an 'y' data vector
   th = Sig*randn + Sig*randn(1,sz);   % create a 'th' vector

      % create a cordoba object with t,x,y & th

   oo = cordoba(typ);               % construct CORDOBA object
   switch typ
      case 'bmc'
         oo = trace(oo,t,'x',x,'y',y,'th',th);
      case 'vuc'
         x = 1000 + x/4 + t*drift/max(t) + jump*sign(t-max(t)/2);
         y = 1000 + y/4 - t*drift/max(t) - jump*sign(t-max(t)/2);
         oo = trace(oo,t,'x',x,'y',y);
         oo.type = 'vib';
         oo.par.kind = 'uc';
         oo.par.system = get(o,'system');
      case 'vsc'
         x = 1000 + x/4 - t*drift/max(t) + jump*sign(t-max(t)/2);
         y = 1000 + y/4 + t*drift/max(t) - jump*sign(t-max(t)/2);
         oo = trace(oo,t,'x',x,'y',y);
         oo.type = 'vib';
         oo.par.kind = 'sc';
         oo.par.system = get(o,'system');
   end

   machine = get(o,{'machine','95000000000'});
   package = get(o,{'package',[]});
   project = get(o,{'project',''});
   
   system = get(o,{'system','L'});
   oo = set(oo,'system',system);
   oo = set(oo,'sizes',[m,n,r]);    % set data sizes
   oo = set(oo,'method','blcs');    % set processing method

      % provide title & comments for the caracook object

   [date,time] = o.now;
   system = get(o,'system');
   
   sys = o.iif(system,[' (',system,')'],'');
   oo = set(oo,'title',[o.now(date,time),' ',upper(typ),' Data',sys]);
   oo = set(oo,'comment',{'(gaussian random data)',['Type: ',oo.type]});
   oo = set(oo,'date',date,'time',time);
   oo = set(oo,'machine',machine,'project',project,'package',package);

      % provide plot defaults and paste object into shell
      % and display object's info on screen

   oo = Config(oo);                 % setup plot configuration
end

%==========================================================================
% Configuration (Type: pln, smp, vib, bmc)
%==========================================================================

function oo = Config(o)                % Configure Object              
   switch o.type
      case {'vib','bmc'}
         oo = basis(o,'Config');       % delegate to basis/Config
      case {'pln','plain'}
         oo = sample(o,'Config');      % delegate to sample/Config 
      case {'smp','simple'}
         oo = sample(o,'Config');      % delegate to sample/Config 
      otherwise
         oo = read(o,'Config');        % delegate to read driver Config 
   end
end

%==========================================================================
% New Machine Number
%==========================================================================

function machine = Machine(o)          % New Machine Number            
   machine = sprintf('9508860%04.0f',round(1e4*rand));
end
