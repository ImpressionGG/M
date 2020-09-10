function oo = study(o,varargin)        % Study Menu                    
%
% STUDY   Manage Study menu
%
%           study(o,'Setup');          %  Setup Study menu
%
%           study(o,'Study1');         %  Study 1
%           study(o,'Study2');         %  Study 2
%           study(o,'Study3');         %  Study 3
%           study(o,'Study4');         %  Study 4
%
%           study(o,'Signal');          %  Setup STUDY specific Signal menu
%
%        See also: TRF, SHELL, PLOT
%
   [gamma,oo] = manage(o,varargin,@Setup,@Signal,@Config,...
                @Study1,@Study2,@Study3,@Study4,@Signal,@MotionPlot,...
                @MotionProfile,@DutyProfile,@ClipPlot,@MotionMap,@DutyMap);
   oo = gamma(oo);
end

%==========================================================================
% Setup Study Menu
%==========================================================================

function o = Setup(o)                  % Setup Study Menu              
   Register(o);
   
   oo = mhead(o,'Study');
   ooo = mitem(oo,'Sinc',{@invoke,mfilename,@Study1});
   ooo = mitem(oo,'Trigonometric',{@invoke,mfilename,@Study2});
   ooo = mitem(oo,'Exponential',{@invoke,mfilename,@Study3});
   ooo = mitem(oo,'Damped Oscillation',{@invoke,mfilename,@Study4});
   ooo = mitem(oo,'-');
   ooo = Parameters(oo);
end
function o = Register(o)               % Register Some Stuff           
   Config(type(o,'motstudy'));         % register 'motstudy' configuration
   Config(type(o,'trigo'));            % register 'trigo' configuration
   Config(type(o,'expo'));             % register 'expo' configuration
   name = class(o);
   plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
end

%==========================================================================
% View
%==========================================================================

function o = Signal(o)                 % Simu Specific Signal Menu     
%
% SIGNAL   The Sinal function is responsible for both setting up the 
%          'Signal' menu head and the subitems which are dynamically 
%          depending on the type of the current object
%
   switch active(o);                   % depending on active type
      case {'trigo','expo'}
         oo = mitem(o,'X',{@Config},'ConfigX');
         oo = mitem(o,'Y',{@Config},'ConfigY');
         oo = mitem(o,'X/Y',{@Config},'ConfigXY');
         oo = mitem(o,'X and Y',{@Config},'ConfigXandY');
      case {'motstudy'}
         oo = mitem(o,'V',{@Config},'ConfigV');
         oo = mitem(o,'S',{@Config},'ConfigS');
         oo = mitem(o,'V/S',{@Config},'ConfigVS');
         oo = mitem(o,'-');
         oo = mitem(o,'A',{@Config},'ConfigA');
         oo = mitem(o,'J',{@Config},'ConfigJ');
         oo = mitem(o,'A/J',{@Config},'ConfigAJ');
         oo = mitem(o,'-');
         oo = mitem(o,'V/S/A',{@Config},'ConfigVSA');
         oo = mitem(o,'V/S/A/J',{@Config},'ConfigVSAJ');
   end
end
function o = Config(o)                 % Install a Configuration       
   o = config(o,[],active(o));         % init, using active type
   o = subplot(o,'layout',1);          % layout with 1 subplot column   
   o = category(o,1,[-2 2],[],'µ');    % setup category 1
   o = category(o,2,[-2 2],[],'µ');    % setup category 2
   o = category(o,3,[0,0],[],'mm');    % setup category 3 (motion s)
   o = category(o,4,[],[],'mm/s');     % setup category 4 (motion v)
   o = category(o,5,[],[],'mm/s2');    % setup category 5 (motion a)
   o = category(o,6,[],[],'mm/s3');    % setup category 6 (motion j)
   
   switch type(o)
      case 'expo'
         colx = 'm';  coly = 'c';
      otherwise
         colx = 'r';  coly = 'b';
   end
   
   mode = o.either(arg(o,1),type(o));  % get mode - use type as default
   switch mode
      case {'ConfigX'}
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
      case {'ConfigY'}
         o = config(o,'y',{1,coly});   % configure 'y' for 2nd subplot
      case {'ConfigXY'}
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
         o = config(o,'y',{1,coly});   % configure 'y' for 2nd subplot
      case {'ConfigXandY','expo','trigo'}
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
         o = config(o,'y',{2,coly});   % configure 'y' for 2nd subplot
         mode = 'ConfigXandY';

      case {'ConfigV'}
         o = config(o,'v',{1,'b',4});  % configure 'v' @ subplot #1, cat 4
      case {'ConfigS'}
         o = config(o,'s',{1,'g',3});  % configure 'v' @ subplot #1, cat 3
      case {'ConfigVS','motstudy'}
         o = config(o,'v',{1,'b',4});  % configure 'v' @ subplot #1, cat 4
         o = config(o,'s',{2,'g',3});  % configure 's' @ subplot #2, cat 3
         mode = 'ConfigVS';
      case {'ConfigA'}
         o = config(o,'a',{1,'r',5});  % configure 'v' @ subplot #1, cat 5
      case {'ConfigJ'}
         o = config(o,'j',{1,'yo',6}); % configure 'j' @ subplot #1, cat 6
      case {'ConfigAJ'}
         o = config(o,'a',{1,'b',5});  % configure 'a' @ subplot #1, cat 5
         o = config(o,'j',{2,'yo',6}); % configure 'j' @ subplot #2, cat 6
      case {'ConfigVSA'}
         o = config(o,'v',{1,'b',4});  % configure 'v' @ subplot #1, cat 4
         o = config(o,'s',{2,'g',3});  % configure 's' @ subplot #2, cat 3
         o = config(o,'a',{3,'r',5});  % configure 'a' @ subplot #3, cat 5
      case {'ConfigVSAJ'}
         o = config(o,'v',{1,'b',4});  % configure 'v' @ subplot #1, cat 4
         o = config(o,'s',{2,'g',3});  % configure 's' @ subplot #2, cat 3
         o = config(o,'a',{3,'r',5});  % configure 'a' @ subplot #3, cat 5
         o = config(o,'j',{4,'yo',6}); % configure 'j' @ subplot #4, cat 6
   end
   o = subplot(o,'Signal',mode);       % store signal mode
   
   change(o,'Bias','absolute');        % change bias
   change(o,'Config');                 % change config, rebuild & refresh
end

%==========================================================================
% Studies
%==========================================================================

function o = Study1(o)                 % Study 1 - Sinc Function       
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
function o = Study2(o)                 % Study 2 - Trigonometric       
%
% STUDY2 Trigonometric simulation data is stored in a CARAMEL object of
%        type 'trigo' and plotted. 
%
%        The CARAMEL object is also stored into clipboard for potential
%        paste and subsequent analysis in more detail. If pasted (with
%        Edit>Paste) object can be further analyzed.
%
%        Use 'Plot>Stream Plot X', 'Plot>Stream Plot Y' or 'Plot/Scatter
%        Plot' for plotting, or use 'Plot>Basic>Stream' for plotting
%        while switching signal configurations in View/Signal menu.
%
   oo = caramel('trigo');              % create a 'trigo' typed TRF object
   oo = log(oo,'t','x','y');           % setup a data log object

      % setup parameters and system matrix
      
   om = opt(o,'study.omega');  T = opt(o,'study.T');  % some parameters
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
function o = Study3(o)                 % Study 3 - Exponential         
%
% STUDY3 Exponential simulation data is stored in a CARAMEL object of
%        type 'expo' and plotted. 
%
%        The CARAMEL object is also stored into clipboard for potential
%        paste and subsequent analysis in more detail. If pasted (with
%        Edit>Paste) object can be further analyzed.
%
%        Use 'Plot>Stream Plot X', 'Plot>Stream Plot Y' or 'Plot/Scatter
%        Plot' for plotting, or use 'Plot>Basic>Stream' for plotting
%        while switching signal configurations in View/Signal menu.
%
   oo = caramel('expo');               % create an 'expo' typed object
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
function o = Study4(o)                 % Study 4 - Repeated Simulation 
%
% STUDY4 Repeated simulation data is stored in a CARAMEL object of type
%        'trigo', stored into clipboard for potential paste and plotted.
%
%        If pasted (with Edit>Paste) object can be further analyzed using
%        'Plot>Stream Plot'.
%        Use 'Plot>Stream Plot X', 'Plot>Stream Plot Y' or 'Plot/Scatter
%        Plot' for plotting, or use 'Plot>Basic>Stream' for plotting
%        while switching signal configurations in View/Signal menu.
%
   oo = caramel('trigo');              % create an 'trigo' typed object
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

