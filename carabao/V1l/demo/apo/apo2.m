function o = apo2(o,varargin)          % APO (Version #2)              
%
% APO2   Automatic Position Optimization (Version #2)
%
%           apo2;                      % launch APO2 shell
%
%        Next steps:
%           - provide a shell defaults (title, comment, category, config)
%           - provide a 'Create' menu item
%           - provide a 'Plot' menu item
%
%        See also: TRACE
%
   if (nargin == 0)                    % need to init object?
      o = carma(mfilename);            % create a CARMA object
   end
   [gamma,oo] = manage(o,varargin,@Shell);
   oo = gamma(o);                      % dispatch to managed function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);                        % initialize shell object

   o = menu(o,'Begin');                % begin menu setup
   oo = Study(o);                      % add Study menu
   o = menu(o,'End');                  % end menu setup
end
function o = Init(o)                   % Initialize Shell Object       
   o = dynamic(o,false);               % setup as a static shell
   o = launch(o,mfilename);            % setup launch function
   o = refresh(o,{'menu','About'});    % provide refresh callback function

   o = provide(o,'par.title','APO2 Shell');
   o = provide(o,'par.comment',{'Auto Position Optimization','(Version #2)'});

   if (category(o,inf) == 0)
      o = category(o,1,[-3 3],[],'µ'); % category #1: spec, scale and unit
   end
   if (config(o,inf) == 0)
      o = config(o,'+');               % let shell define configuration
      o = config(o,'x',{1,'r',1});     % provide subplot#, color, category#
   end
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu                    
   oo = mhead(o,'Study');              % create new menu
   ooo = mitem(oo,'Create Sample',{@CreateSample});
   ooo = mitem(oo,'Plot Sample',{@PlotSample});
end
function o = CreateSample(o)           % Create Sample Callback        
   t = 1:100;                          % crate a time vector
   x = 2 + 0.2*randn(size(t));         % create an 'x' data vector
   oo = trace(carma,t,'x',x);      % pack t and x into a trace object
   
      % provide title & comments for the trace object
      
   oo = set(oo,'title',[o.now,' Sample Data']);
   oo = set(oo,'comment','data with offset 2µ and 0.2µ sigma');
   
      % paste object into shell and display shell info on screen
      
   paste(o,{oo});                      % paste new trace into shell
end
function o = PlotSample(o)             % Plot Sample Callback          
   cls(o);                             % clear screen
   oo = current(o);                    % get current object
   plot(oo);                           % plot object
end
