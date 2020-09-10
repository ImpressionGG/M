function o = apo3(o,varargin)          % APO (Version #3)              
%
% APO3   Automatic Position Optimization (Version #3)
%
%           apo3                       % launch APO3 shell
%
%        Next steps:
%           - provide standard menu items
%           - add a shell trailer to support standard menu functions
%           - provide category and configuration in 'Shell'
%
%        See also: TRACE
%
   if (nargin == 0)                    % need to init object?
      o = trace(mfilename);            % create trace object
   end
   
   [cmd,o] = arguments(o,varargin,'Shell');
   o = eval(cmd);                      % dispatch to local function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Default(o);
   
   menu(o,'Begin');                    % begin shell setup
   menu(o,'File');                     % add File menu
   menu(o,'Edit');                     % add Edit menu
   menu(o,'View');                     % add View menu
   menu(o,'Select');                   % add Select menu
   menu(o,'Plot');                     % add Plot menu
   apo3(o,'Study');                    % add Study menu
   menu(o,'Info');                     % add Info menu
   menu(o,'End');                      % end shell setup
   
   o = trailer(o);                     % trailer supports standard func's
end

function o = Default(o)                % Provide Shell Defaults        
   o = provide(o,'title','APO3 Shell');
   o = provide(o,'comment',{'Auto Position Optimization','(Version #3)'});

   if (category(o,inf) == 0)
      o = category(o,1,[-3 3],[],'µ'); % category #1: spec, scale and unit
   end
   if ~config(o,inf) && property(o,'config?')
      o = config(o,'+');               % let shell define configuration
      o = config(o,'x',{1,'r',1});     % provide subplot#, color, category#
   end
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu                    
   call = @bazaar.call;
   oo = mitem(o,'Study');              % create new menu
   ooo = mitem(oo,'Create Sample',call('Create'));
   ooo = mitem(oo,'Plot Sample',call('Plot'));
end

function oo = Create(o)                % Create a Trace Object         
   t = 1:100;                          % crate a time vector
   x = 2 + 0.2*randn(size(t));         % create an 'x' data vector
   oo = trace(t,'x',x);                % pack t and x into a trace object
   
      % provide title & comments for the trace object
      
   oo = set(oo,'title',[now(o),' Sample Data']);
   oo = set(oo,'comment','data with offset 2µ and 0.2µ sigma');
   
      % paste object into shell and display shell info on screen
      
   paste(oo);                          % paste new object into shell
end

function oo = Plot(o)                  % Plot Trace Object             
   cls(o);                             % clear screen
   oo = plot(o);                       % plot object
end
