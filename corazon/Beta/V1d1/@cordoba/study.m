function oo = study(o,varargin)        % Study Menu                    
%
% STUDY   Manage Study menu
%
%           study(o,'Setup');          %  Setup STUDY menu
%
%           study(o,'Study1');         %  Study 1
%           study(o,'Study2');         %  Study 2
%           study(o,'Study3');         %  Study 3
%           study(o,'Study4');         %  Study 4
%
%           study(o,'Signal');         %  Setup STUDY specific Signal menu
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORDOBA, SHELL, PLOT
%
   [gamma,oo] = manage(o,varargin,@Setup,@Config,@Signal,...
                                  @Study1,@Study2,@Study3,@Study4);
   oo = gamma(oo);
end

%==========================================================================
% Setup Study Menu
%==========================================================================

function o = Setup(o)                  % Setup Study Menu              
   menu = opt(o,{'study.menu',false}); % study menu enabled?
   if ~menu
      return                           % bye, if not enabled
   end
   
   Register(o);
   
   oo = mhead(o,'Study');
   ooo = mitem(oo,'Sinc',{@invoke,mfilename,@Study1});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Trigonometric',{@Study2});
   ooo = mitem(oo,'Exponential',{@Study3});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Damped Oscillation',{@Study4});
   ooo = mitem(oo,'-');
   ooo = Parameters(oo);
end
function o = Register(o)               % Register Some Stuff           
   Config(type(o,'trigo'));            % register 'trigo' configuration
   Config(type(o,'expo'));             % register 'expo' configuration
   name = class(o);
   plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
end

%==========================================================================
% Configuration
%==========================================================================

function o = Signal(o)                 % Study Specific Signal Menu    
%
% SIGNAL   The Signal function is setting up type specific Signal menu 
%          items which allow to change the configuration.
%
   switch active(o);                   % depending on active type
      case {'trigo','expo'}
         oo = mitem(o,'X',{@Config},'X');
         oo = mitem(o,'Y',{@Config},'Y');
         oo = mitem(o,'X/Y',{@Config},'XY');
         oo = mitem(o,'X and Y',{@Config},'XandY');
   end
end
function o = Config(o)                 % Install a Configuration
%
% CONFIG Setup a configuration
%
%           Config(type(o,'mytype'))   % register a type specific config
%           oo = Config(arg(o,{'XY'})  % change configuration
%
   mode = o.either(arg(o,1),'XandY');  % get mode or provide default

   o = config(o,[],active(o));         % set all sublots to zero
   o = subplot(o,'Layout',1);          % layout with 1 subplot column   
   o = subplot(o,'Signal',mode);       % set signal mode   
   o = category(o,1,[-2 2],[],'�');    % setup category 1
   o = category(o,2,[-2 2],[],'�');    % setup category 2
   
   switch type(o)                      % depending on active type
      case 'expo'
         colx = 'm';  coly = 'c';
      otherwise
         colx = 'r';  coly = 'b';
   end
      
   switch mode
      case {'X'}
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
      case {'Y'}
         o = config(o,'y',{1,coly});   % configure 'y' for 2nd subplot
      case {'XY'}
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
         o = config(o,'y',{1,coly});   % configure 'y' for 2nd subplot
      otherwise
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
         o = config(o,'y',{2,coly});   % configure 'y' for 2nd subplot
   end
   change(o,'Config');
end

%==========================================================================
% Study
%==========================================================================

function o = Study1(o)                 % Study 1                       
%
% STUDY1  Uses standard MATLAB functions. Plots cannot be configured
%
   om = 3*opt(o,'study.omega');        % omega

      % run the system
      
   t = 0:0.01:1;   
   x = sin(om*t)./(om*t);  x(1) = 1;
   
      % plot graphics and provide title
      
   cls(o);  plot(t,x,'g'); 
   title('Sinc Function');  shg;
end
function o = Study2(o)                 % Study 2                       
%
% STUDY2 Simulation data is stored in a PLAY object of type 'trigo',
%        stored into clipboard for potential paste and plotted. If
%        pasted (with Edit>Paste) object can be further analyzed using
%        'Plot>Stream Plot'.
%        Use 'Plot>Stream Plot X', 'Plot>Stream Plot Y' or 'Plot/Scatter
%        Plot' for plotting, or use 'Plot>Basic>Stream' for plotting
%        while switching signal configurations in View/Signal menu.
%
   oo = cordoba('trigo');              % create a 'trigo' typed object
   oo = log(oo,'t','x','y');           % setup a data log object

      % setup parameters and system matrix
      
   om = opt(o,'study.omega');  T = opt(o,'study.T');    % some parameters
   A = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % system matrix
   
      % run the system
      
   x = [0 1]';                         % init system state  
   for k = 1:100;
      t = k*T;                         % actual time stamp
      y = x + 0.1*randn(2,1);          % system output
      
      oo = log(oo,t,y(1),y(2));        % record log data
      x = A*x;                         % state transition
   end
   
      % define as working object, provide title and plot graphics
      
   oo = set(oo,'title',['Trigonometric @',o.now]);
   plot(oo);                           % plot graphics
end
function o = Study3(o)                 % Study 3                       
%
% STUDY3 Simulation data is stored in a PLAY object of type 'expo',
%        stored into clipboard for potential paste and plotted. If
%        pasted (with Edit>Paste) object can be further analyzed using
%        'Plot>Stream Plot'.
%        Use 'Plot>Stream Plot X', 'Plot>Stream Plot Y' or 'Plot/Scatter
%        Plot' for plotting, or use 'Plot>Basic>Stream' for plotting
%        while switching signal configurations in View/Signal menu.
%
   oo = cordoba('expo');               % create an 'expo' typed object
   oo = log(oo,'t','x','y');           % setup a data log object

         % setup parameters and system matrix
      
   T = opt(o,'study.T');
   d = exp([opt(o,'study.damping1'), opt(o,'study.damping2')] * T);
   A = diag(d);                        % system matrix
   
      % run the system
   
   x = [1.5 -0.5]';                    % init system state
   for k = 0:100;
      t = k*T;                         % actual time stamp
      y = x + 0.1*randn(2,1);          % system output
      
      oo = log(oo,t,y(1),y(2));        % record log data
      x = A*x;                         % state transition
   end

      % define as working object, provide title and plot graphics
      
   oo = set(oo,'title',['Exponential @ ',o.now]);
   plot(oo);                           % plot graphics
end
function o = Study4(o)                 % Study 4                       
%
% STUDY4 Repeated simulation data is stored in a PLAY object of type
%        'trigo', stored into clipboard for potential paste and plotted.
%        If pasted (with Edit>Paste) object can be further analyzed using
%        'Plot>Stream Plot'.
%        Use 'Plot>Stream Plot X', 'Plot>Stream Plot Y' or 'Plot/Scatter
%        Plot' for plotting, or use 'Plot>Basic>Stream' for plotting
%        while switching signal configurations in View/Signal menu.
%
   oo = cordoba('trigo');              % create an 'trigo' typed object
   oo = log(oo,'t','x','y');           % setup a data log object

         % setup parameters and system matrix
      
   T = opt(o,'study.T');
   om = opt(o,'study.omega');
   d = exp(opt(o,'study.damping1')*T);
   S = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % oscillation
   A = S*diag([d d]);                  % system matrix
   
      % run the system
   
   t = 0;
   for i = 1:10                        % 10 repeats                    
      oo = log(oo);                    % next repeat
      x = [1.5 -0.5]';                 % init time & system state
      for k = 0:100;
         y = x + 0.1*randn(2,1);       % system output
      
         oo = log(oo,t,y(1),y(2));     % record log data
         x = A*x;                      % state transition
         t = t + T;                    % time transition
      end
   end

      % define as working object, provide title and plot graphics
      
   oo = set(oo,'title',['Damped Oscillation @ ',o.now]);
   plot(oo);                           % plot graphics
end

%==========================================================================
% Parameters
%==========================================================================

function oo = Parameters(o)            % Parameters Sub Menu           
   setting(o,{'study.T'},1/100);
   setting(o,{'study.omega'},2*pi);
   setting(o,{'study.damping1'},-2);
   setting(o,{'study.damping2'},1);
   
   oo = mitem(o,'Parameters');
   ooo = mitem(oo,'Omega','','study.omega'); 
         charm(ooo,{});
   ooo = mitem(oo,'Damping 1','','study.damping1'); 
         charm(ooo,{});
   ooo = mitem(oo,'Damping 2','','study.damping2'); 
         charm(ooo,{});
end

