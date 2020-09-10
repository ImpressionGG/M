function oo = study(o,varargin)         % Simulation Menu               
%
% SIMU   Manage simulation menu
%
%           study(o,'Setup');           %  Setup SIMU menu
%
%           study(o,'Study1');          %  Study 1
%           study(o,'Study2');          %  Study 2
%           study(o,'Study3');          %  Study 3
%           study(o,'Study4');          %  Study 4
%
%           study(o,'Signal');          %  Setup STUDY specific Signal menu
%
%        See also: HAR, SHELL, PLOT
%
   [gamma,oo] = manage(o,varargin,@Setup,@Signal,@Analyse,...
                                  @Study1,@Study2,@Study3,@Study4);
   oo = gamma(oo);
end

%==========================================================================
% Setup Simu Menu
%==========================================================================

function o = Setup(o)                  % Setup Simulation Menu         
   setting(o,{'V'},3.14);
   setting(o,{'Ti'},2.71);

   Register(o);
   
   oo = mhead(o,'Study');
   ooo = mitem(oo,'Sinc',{@invoke,mfilename,@Simu1});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Trigonometric',{@invoke,mfilename,@Simu2});
   ooo = mitem(oo,'Exponential',{@invoke,mfilename,@Simu3});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Damped Oscillation',{@invoke,mfilename,@Simu4});
   ooo = mitem(oo,'-');
   ooo = Parameters(oo);
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'My Additional Parameters');
   oooo = mitem(ooo,'Gain V',{},'V');
          charm(oooo,{});
   oooo = mitem(ooo,'Time Constant Ti',{},'Ti');
          charm(oooo,{});
end
function o = Register(o)               % Register Some Stuff           
   o = Config(type(o,'trigo'));        % register 'trigo' configuration
   o = Config(type(o,'expo'));         % register 'expo' configuration
   name = class(o);
   plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
end

%==========================================================================
% Configuration
%==========================================================================

function o = Config(o)                 % Install a Configuration       
   mode = arg(o,1);
   mode = o.iif(isempty(mode),type(o),mode);
   
   o = config(o,[]);                   % set all sublots to zero
   o = config(o,'');                   % configure defaults for time
   o = subplot(o,'layout',1);          % layout with 1 subplot column   
   o = category(o,1,[-2 2],[0 0],'µ'); % setup category 1
   o = category(o,2,[-2 2],[0 0],'µ'); % setup category 2
   
   switch type(o)
      case 'expo'
         colx = 'm';  coly = 'c';
      otherwise
         colx = 'r';  coly = 'b';
   end
   switch mode
      case {'ConfigX'}
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
      case {'ConfigY'}
         o = config(o,'y',{1,coly});   % configure 'y' for 2nd subplot
      case {'ConfigXY'}
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
         o = config(o,'y',{1,coly});   % configure 'y' for 2nd subplot
      otherwise
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
         o = config(o,'y',{2,coly});   % configure 'y' for 2nd subplot
   end
   change(o,'config',o);               % change config, rebuild & refresh
end
function o = Signal(o)                 % Simu Specific Signal Menu                   
%
% SIGNAL   The Sinal function is responsible for both setting up the 
%          'Signal' menu head and the subitems which are dynamically 
%          depending on the type of the current object
%
   switch active(o);                   % depending on active type
      case {'trigo','expo'}
         oo = mitem(o,'X',{@Config,'ConfigX'});
         oo = mitem(o,'Y',{@Config,'ConfigY'});
         oo = mitem(o,'X/Y',{@Config,'ConfigXY'});
         oo = mitem(o,'X and Y',{@Config,'ConfigXandY'});
   end
end

%==========================================================================
% Simulations
%==========================================================================

function o = Study1(o)                  % Study 1                  
%
% STUDY1  Uses standard MATLAB functions. Plots cannot be configured
%
   om = 3*opt(o,'study.omega');         % omega

      % run the system
      
   t = 0:0.01:1;   
   x = sin(om*t)./(om*t);  x(1) = 1;
   
      % plot graphics and provide title
      
   cls(o);  plot(t,x,'g'); 
   title('Sinc Function');  shg
end
function o = Study2(o)                  % Study 2                  
%
% STUDY2 Simulation data is stored in a HAR object of type 'trigo',
%        stored into clipboard for potential paste and plotted. If
%        pasted (with Edit>Paste) object can be further analyzed using
%        'Plot>Stream Plot'.
%        Use 'Plot>Stream Plot X', 'Plot>Stream Plot Y' or 'Plot/Scatter
%        Plot' for plotting, or use 'Plot>Basic>Stream' for plotting
%        while switching signal configurations in View/Signal menu.
%
   oo = har('trigo');                % create a 'trigo' typed object
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
   
      % provide title and plot graphics
      
   oo = set(oo,'title',['Trigonometric @',o.now]);
   graph(oo);                          % plot graphics & put in clip board
end
function o = Study3(o)                 % Study 3                  
%
% STUDY3 Simulation data is stored in a HAR object of type 'expo',
%        stored into clipboard for potential paste and plotted. If
%        pasted (with Edit>Paste) object can be further analyzed using
%        'Plot>Stream Plot'.
%        Use 'Plot>Stream Plot X', 'Plot>Stream Plot Y' or 'Plot/Scatter
%        Plot' for plotting, or use 'Plot>Basic>Stream' for plotting
%        while switching signal configurations in View/Signal menu.
%
   oo = har('expo');                 % create an 'expo' typed object
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

      % provide title and plot graphics
      
   oo = set(oo,'title',['Exponential @ ',o.now]);
   graph(oo);                          % plot graphics & put in clip board
end
function o = Study4(o)                 % Study 4                  
%
% STUDY4 Repeated simulation data is stored in a HAR object of type
%        'trigo', stored into clipboard for potential paste and plotted.
%        If pasted (with Edit>Paste) object can be further analyzed using
%        'Plot>Stream Plot'.
%        Use 'Plot>Stream Plot X', 'Plot>Stream Plot Y' or 'Plot/Scatter
%        Plot' for plotting, or use 'Plot>Basic>Stream' for plotting
%        while switching signal configurations in View/Signal menu.
%
   oo = har('trigo');                % create an 'trigo' typed object
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
      x = [1.5 -0.5]';         % init time & system state
      for k = 0:100;
         y = x + 0.1*randn(2,1);       % system output
      
         oo = log(oo,t,y(1),y(2));     % record log data
         x = A*x;                      % state transition
         t = t + T;                    % time transition
      end
   end

      % provide title and plot graphics
      
   oo = set(oo,'title',['Damped Oscillation @ ',o.now]);
   graph(oo);                          % plot graphics & put in clip board
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

