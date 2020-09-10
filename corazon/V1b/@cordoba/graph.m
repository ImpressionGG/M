function oo = graph(o,varargin)   % Plot Graph of a Trace Object           
%
% GRAPH  Plot graph of a CORDOBA trace object (or derived). At the same
%        time put object into clipboard for pasting into object list.
%        GRAPH calls method PLOT.
%
%           graph(o)                   % graphics plot with default mode 
% 
%        Default mode is according to the the setting(o,'mode.plot'), 
%        which is updated according menu item selection in Plot Menu
%
%           graph(o,'Stream')          % plot in stream mode
%           graph(o,'Overlay')         % plot in overlay mode
%           graph(o,'Offset')          % plot individual offsets
% 
%           graph(o,'Repeatability')   % plot repeatability stream
%           graph(o,'Fictive Stream')  % plot repeatability stream
% 
%           graph(o,'Ensemble')        % plot ensemble of data lines
%           graph(o,'Averages')        % plot individual offsets
%           graph(o,'Spread')          % plot sigma values of ensemble
%           graph(o,'Deviation')       % plot deviation of an ensemble
%
%        Enhanced analysis
%
%           graph(o,'Path');           % plot graphics of matrix path
%
%        Options: the following options influence the plotting behavior
% 
%           'mode'        % plot mode ('mode.plot')
%           'style'       % plot style (line width, bullets,labels)
%           'view'        % view options
%           'grid'        % grid on/off
%           'scope'       % scope of data stream (matrix indices)
%
%    Example:
% 
%       o = config(pull(cordoba),[]);  % set all sublots to zero
%       o = config(o,'');              % configure defaults for time
%       o = subplot(o,'layout',1);     % layout with 1 subplot column   
%       o = category(o,1,[-2 2],[0 0],'�'); % setup category 1
%       o = config(o,'x',{1,'r'});     % configure 'x' for 1st subplot
%       o = config(o,'y',{1,'r'});     % configure 'y' for 1st subplot
%       change(o,'config',o);
%       
%       t = 0:pi/50:4*pi;  x = sin(t); y = cos(t);
%       o = trace(t,'x',x,'y',y);
%       graph(o);                       % same as graph(o,'Stream')
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORDOBA, CONFIG, PLOT
%
   [gamma,oo] = manage(o,varargin,@Default,@Stream,@Fictive,@Overlay,...
        @Offsets,@Repeatability,@Residual1,@Residual2,@Residual3,...
        @Ensemble,@Average,@Spread,@Deviation,...
        @Condensate1,@Condensate2,@Condensate3);
   oo = gamma(oo);
end

function o = Default(o)                % Plot in Default Mode          
   mode = o.either(setting(o,'mode.plot'),'Stream'); 
   graph(o,mode);
end

%==========================================================================
% Local Functions to be Dispatched
%==========================================================================

function oo = Stream(o)                % Stream Plot                   
   oo = Graph(o,'Stream');
end
function oo = Fictive(o)               % Fictive Stream Plot           
   oo = Graph(o,'Fictive');
end

function oo = Overlay(o)                                               
   oo = Graph(o,'Overlay');
end
function oo = Offsets(o)                                               
   oo = Graph(o,'Offsets');
end
function oo = Repeatability(o)                                         
   oo = Graph(o,'Repeatability');
end
function oo = Residual1(o)                                             
   oo = Graph(o,'Residual1');
end
function oo = Residual2(o)                                             
   oo = Graph(o,'Residual2');
end
function oo = Residual3(o)                                             
   oo = Graph(o,'Residual3');
end

function oo = Ensemble(o)                                              
   oo = Graph(o,'Ensemble');
end
function oo = Average(o)                                               
   oo = Graph(o,'Average');
end
function oo = Spread(o)                                                
   oo = Graph(o,'Spread');
end
function oo = Deviation(o)                                             
   oo = Graph(o,'Deviation');
end

function oo = Condensate1(o)           % Condensate1 Plot              
   oo = Graph(o,'Condensate1');
end
function oo = Condensate2(o)           % Condensate2 Plot              
   oo = Graph(o,'Condensate2');
end
function oo = Condensate3(o)           % Condensate3 Plot              
   oo = Graph(o,'Condensate3');
end

%==========================================================================
% Plot and Put Into Clip Board
%==========================================================================

function oo = Graph(o,mode)            % plot & put into clip board    
   oo = inherit(o,pull(o));            % inherit work properties properly
   
%  atype = active(oo);
%  if ~isequal(atype,oo.type)
%     active(oo,oo.type);
%     %event(pull(o),'signal');        % e.g., change View>Signal menu
%     event(oo,'signal');              % e.g., change View>Signal menu
%     oo = opt(oo,'refresh',0);        % inhibit refreshing
%     change(oo,'Signal');             % update Signal menu
%  end

   active(o,oo);                       % make sure oo.type is active
   
   if (nargin == 1)
      mode = setting(oo,{'mode.plot','Stream'});
   end

      % the next lines are needed to make the refresh after a new
      % object selection working properly!
   
   about = caller(oo,'Activate');
   about = about || caller(oo,'PasteCb');
   
   if (about)                          % better to show 'About' screen?
      menu(current(oo),'About');
      return
   end   
   
   %o = opt(o,setting(o));
   %clip(o,o);
   
      % we cast object completely to a CORDOBA object before we put
      % it into the clipboard. This allows to leverage the dynamic 
      % plot menu of CORDOBA objects
   
   oc = cast(oo,'cordoba');
   oc.tag = 'cordoba';                 % complete conversion to cordoba
   clip(oc,oo);
      
   oo = with(oo,'style');              % unpack 'style' options
   oo = with(oo,'view');               % unpack 'view' options
   oo = with(oo,'select');             % unpack 'select' options

   plot(oo,mode);
end

