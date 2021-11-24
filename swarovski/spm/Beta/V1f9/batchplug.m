function oo = batchplug(o,varargin)   % Batchplug Plugin              
%
% BATCHPLUG Batchplug plugin: Add batch menu items
%
%              batchplug(sho)         % plugin registration
%
%              oo = batchplug(o,func) % call local batchplug function
%
%           See also: CORAZON, PLUGIN, SAMPLE, SIMPLE, SPMHACK
%
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Menu,...
                       @WithCuo,@WithSho,@CritNichols);
   oo = gamma(oo);
end              

%==========================================================================
% Plugin Setup & Registration
%==========================================================================

function o = Setup(o)                  % Setup Registration            
   o = Register(o);                    % register plugins
   rebuild(o);                         % rebuild menu
end
function o = Register(o)               % Plugin Registration           
   tag = class(o);
   plugin(o,[tag,'/menu/End'],{mfilename,'Menu'});
   plugin(o,[tag,'/current/Select'],{mfilename,'Menu'});
end

%==========================================================================
% Launch Callbacks
%==========================================================================

function oo = WithSho(o)               % 'With Shell Object' Callback  
%
% WITHSHO General callback for operation on shell object
%         with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,{@batch,'About'});        % display About message on refresh

   mode = dark(o);
   dark(o,0);
   o = dark(o,0);                      % disable dark mode for object o
   
   cls(o);                             % clear screen
   
   stop(o,'Enable');
   gamma = eval(['@',mfilename]);
   o = Options(o);                     % set batch options
   oo = gamma(o);                      % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   
   dark(o,mode);                       % restore dark mode
   o = dark(o,mode);                   % restore dark mode for object o
   
   done = var(oo,'done');
   if ~isempty(done)
      cls(o);
      message(o,done);
   end
end
function oo = WithCuo(o)               % 'With Current Object' Callback
%
% WITHCUO A general callback with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,{@batch,'About'});        % display About message on refresh
   
   mode = dark(o);                     % save dark mode
   dark(o,0);                          % disable dark mode shell setting
   o = dark(o,0);                      % disable dark mode for object o
   
   cls(o);                             % clear screen

   oo = current(o);                    % get current object 
   
      % oo = current(o) directly inherits options from shell object,
      % this we have to set dark mode option also for oo!
      
   oo = dark(oo,0);                    % disable dark mode
   
   stop(o,'Enable');
   gamma = eval(['@',mfilename]);
   oo = Options(oo);                   % set batch options
   oo = gamma(oo);                     % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   
   dark(o,mode);                       % restore dark mode (shell settings)
   o = dark(o,mode);                   % restore dark mode for object o
   
   done = var(oo,'done');
   if ~isempty(done)
      cls(o);
      message(o,done);
   end
end

%==========================================================================
% Plugin Definitions
%==========================================================================

function o = Menu(o)                   % Setup General Plugin Menus    
%
% MENU   Setup general plugin menus. General Plugins can be used to plug-
%        in menus at any menu location. All it needs to be done is to
%        locate a menu item by path and to insert a new menu item at this
%        location.
%
   oo = Batch(o);                      % add Batch menu items
end

%==========================================================================
% Plot Menu Plugins
%==========================================================================

function oo = Batch(o)                 % Batch Menu Setup              
%
% BATCH   Add some Batch menu items
%
   oo = mseek(o,{'#','Batch'});        % find Batch rolldown menu
   if isempty(oo)
      return
   end
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Critical Nichols',{@WithCuo, 'CritNichols'});
end

%==========================================================================
% Batch Processing of Critical Nichols Plots
%==========================================================================

function oo = CritNichols(o)              % Process Critical Nichols   
   switch o.type
      case {'spm'}
         oo = CritNicholsSpm(o);
      case {'pkg'}
         oo = CritNicholsPkg(o);
      otherwise
         oo = CritNicholsAll(o);
   end
end

function o = CritNicholsAll(o)            % Run Batch for Shell Object 
   assert(type(o,{'shell'}));
   list = children(o);                  % get list of packages 
   
   for (i=1:length(list))
      oo = list{i};
      CritNicholsPkg(oo);
      if stop(o)
         break
      end
   end
end
function o = CritNicholsPkg(o)            % Run Batch for Package Obj  
   assert(type(o,{'pkg'}));
   list = children(o);                 % get list of SPM objects 
   
   for (i=1:length(list))
      oo = list{i};
      CritNicholsSpm(oo);
      if stop(o)
         break
      end
   end
end
function o = CritNicholsSpm(o)            % Run Batch for SPM Object
   assert(type(o,{'spm'}));
   batch = opt(o,'batch');
   
   if (batch.cutting >= 0)             % forward cutting      
      o = Cls(o,'Critical Nichols (Forward)');
      o = opt(o,'view.cutting',+1);
      analyse(o,'Critical','Nichols');
      Png(o);
   end
      
   if stop(o)                          % time to  stop?
      return
   end
   
   if (batch.cutting <= 0)             % backward cutting      
      o = Cls(o,'Critical Nichols (Backward)');
      o = opt(o,'view.cutting',-1);
      analyse(o,'Critical','Nichols');
      Png(o);
   end
end

%==========================================================================
% Helper
%==========================================================================

function o = Cls(o,title)              % Clear Screen and Setup Tag    
   cls(o);
   Footer(o);

   tag = sprintf('%s - %s',title,id(o));
   fprintf('   plot %s diagram ...\n',tag);
   o = var(o,'tag,tic',tag,tic);
end
function oo = Options(o)
   oo = batch(o,'Options');            % set batch options
   oo = inherit(o,oo);
   oo = arg(oo,arg(o));
end
function Png(o)                        % Write PNG File                
%
% PNG  Create PNG file and take care of a friendly refresj setting
%
%         Png(o)
%
%      This is also a good location to override refresh setting, as
%      we do not want to refresh according to a deeper level setting
%
   tag = var(o,{'tag','$$$'});
   time = toc(var(o,'tic'));
   
   Footer(o,time);
   
   refresh(o,{'batch','About'});
   fprintf('   create PNG file ...\n');
   
   png(o,tag);
end
function Footer(o,time)                % Refresh Footer                
   batch = opt(o,'batch');
   foot = sprintf('SPM V%s, points: %g, eps: %g, pareto: %g%%',...
                  version(o),batch.spectrum.points,batch.critical.eps,...
                  batch.pareto*100);
   if (nargin >= 2)
      foot = sprintf('%s, time: %gs',foot,o.rd(time,1));
   end
   footer(o,foot);
end
