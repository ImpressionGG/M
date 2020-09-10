function oo = new(o,varargin)          % New Object Creation           
%
% NEW   Create new CUT object. Use options
%       'title' and 'comment' to provide title and comment, if required.
%
%       CUL (cut log) objects: containing ax,ay signals
%
%          oo = new(o,'Cul','xtype')   % oo.type = 'xtype'
%          oo = new(o,'Cul','cutlog1') % oo.type = 'cul'
%          oo = new(o,'Cul')           % oo.type = 'cul'
%
%       Cutlog2 objects: containing ax,ay signals
%
%          oo = new(o,'Cutlog2','xtype')   % oo.type = 'xtype'
%          oo = new(o,'Cutlog2','cutlog2') % oo.type = 'cutlog2'
%          oo = new(o,'Cutlog2')           % oo.type = 'cutlog2'
%
%       See also: CUT
%
   [gamma,oo] = manage(o,varargin,@Package,@Cul,@Cutlog2);
   oo = gamma(oo);
end

%==========================================================================
% New String
%==========================================================================

function f = Wave(Tms,f,phi,lambda,width)
   t = 0:0.1:Tms;                      % create a time vector
   om = 2*pi*f/1000;                   % circular frequency [1/ms] 
   tau = (t-max(t)*lambda) / width;
   f = sin(om*t+phi) .* exp(-tau.*tau);
end

%==========================================================================
% New Cul Object
%==========================================================================

function oo = Cul(o)                   % New Simple Object             
   iif = @corazito.iif;                % short hand
   
   typ = o.either(arg(o,1),'cul');     % get type arg
   name = o.capital(typ);              % object name

   T = 0.1;
   t = 0:T:1000;                       % create a time vector
   tmax = max(t);
   f = 1000;                           % 1000 Hz 
   om = 2*pi*f/1000;                   % circular frequency [1/ms] 
   N = 10;
   
   ax = 0*t;
   n = 1 + round(0.5+N*rand);          % random number 1..4
   for (i=1:n)
       f = 1000+20*randn;
       phi = rand*2*pi;
       lambda = rand;
       width = 100*rand;
       ax = ax + Wave(tmax,f,phi,lambda,width);
   end
   r = 0.05*rand;
   ax = ax + r*randn(size(t));
   
   ay = 0*t;
   n = 1 + round(0.5+N*rand);          % random number 1..4
   for (i=1:n)
       f = 1000+20*randn;
       phi = rand*2*pi;
       lambda = rand;
       width = 100*rand;
       ay = ay + Wave(tmax,f,phi,lambda,width);
   end
   r = 0.05*rand;
   ay = ay + r*randn(size(t));
   
   az = 0*t;
   n = 1 + round(0.5+N*rand);          % random number 1..4
   for (i=1:n)
       f = 1000+20*randn;
       phi = rand*2*pi;
       lambda = rand;
       width = 100*rand;
       az = az + Wave(tmax,f,phi,lambda,width);
   end
   r = 0.05*rand;
   az = az + r*randn(size(t));
   
      % calculate bx, by and bz
      
   bx = 1*sin(2*pi*1.0*t) + 2*sin(2*pi*1.1*t) + 2*randn(size(t));
   by = 2*sin(2*pi*0.9*t) + 1*sin(2*pi*1.1*t) + 5*randn(size(t));
   bz = 1*sin(2*pi*1.0*t) + 1*sin(2*pi*1.2*t) + 1*randn(size(t));
   
      % create a cut object with t,x,y

   oo = cut(typ);                        % construct CUT object
   oo = trace(oo,t,'ax',ax,'ay',ay,'az',az,'bx',bx,'by',by,'bz',bz); 

   oo = set(oo,'sizes',[1,length(t),1]); % set data sizes
   oo = set(oo,'method','blrm');         % set processing method

      % provide system
   
   oo = set(oo,'system',iif(rand < 0.5,'L','R'));
   
      % provide title & comments for the caracook object

   [date,time] = o.now;
   comment = {'sin/cos data (random frequency & magnitude)',...
              ['Type: ',oo.type]};

   machine = get(o,{'machine','LPC-X'});
   package = get(o,{'package',[]});
   project = get(o,{'project',''});
           
%  oo = set(oo,'title',[o.now(date,time),' Simple ',o.capital(o.tag)]);
   oo = set(oo,'title',['Cul ',o.capital(o.tag),' @ ',o.now]);
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
% New Cul Object
%==========================================================================

function oo = Cutlog2(o)               % New Simple Object             
   iif = @corazito.iif;                % short hand
   
   typ = o.either(arg(o,1),'cutlog2'); % get type arg
   name = o.capital(typ);              % object name

   m = 1;  n = 1;  r = 1;              % rows x columns x repeats
   t = 0:1000;                         % create a time vector
   sz = size(t);
   om = r*2*pi/max(t);                 % random circular frequency

   ax = (1+3*rand)*sin(om*t)+0.2*randn(sz); % create an 'ax' data vector
   ay = (1+3*rand)*cos(om*t)+0.3*randn(sz); % create an 'ay' data vector

   ax = 10 + ax.*(1+0.2*t/max(t));      % biased & time variant
   ay = 8 + ay.*(1+0.2*t/max(t));       % biased & time variant

      % create a cut object with t,x,y

   oo = cut(typ);                      % construct CUT object
   oo = trace(oo,t,'ax',ax,'ay',ay); 

   oo = set(oo,'sizes',[m,n,r]);       % set data sizes
   oo = set(oo,'method','blrm');       % set processing method

      % provide system
   
   oo = set(oo,'system',iif(rand < 0.5,'L','R'));
   
      % provide title & comments for the caracook object

   [date,time] = o.now;
   comment = {'sin/cos data (random frequency & magnitude)',...
              ['Type: ',oo.type]};

   machine = get(o,{'machine','LPC-X'});
   package = get(o,{'package',[]});
   project = get(o,{'project',''});
           
%  oo = set(oo,'title',[o.now(date,time),' Simple ',o.capital(o.tag)]);
   oo = set(oo,'title',['Cutlog2 ',o.capital(o.tag),' @ ',o.now]);
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

