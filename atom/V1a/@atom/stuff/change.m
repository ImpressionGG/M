function change(o,varargin)            % Change Setting & Rebuild Menu 
%
% CHANGE   Change of important settings with proper event invoking
%          in order to update menus
%
%          1) Change a configuration: changes the a configuration (config
%          settings, subplot settings and category settings) and invokes
%          the 'bias' event to update bias menu. The configuration, subplot
%          and category settings have to be configured by means of an
%          object oo which is passed as arg3.
%
%             change(o,'Config',mode)  => 'config','category','subplot'
%
%          The call change(o,'Config',oo) will automatically invoke a 
%          change(o,'Signal',cblist) call, where cblist is constructed from
%          the calling parameters and the mode argument which is passed as
%          arg(o,1) !!!
%
%          2) Change Overlays or Bias mode: change of Overlay or Bias 
%          settings and subsequent update of Overlays/Bias menu.
%
%             change(o,'Overlays',value) => 'mode.overlays'
%             change(o,'Bias',value)    => 'mode.bias'
%
%          3) Change signal menu according to current selection and
%          activate selected configuration.
%
%             change(o,'Signal')       % update signal menu
%
%          4) Change label style and update Labels menu
%
%             change(o,'Labels','plain')
%             change(o,'Labels','statistics')
%
%          See also: CARAMEL, SETTING, MENU, EVENT, WRAP
%
   o = opt(o,'emptyarg1',isempty(arg(o,1)));
   
      % we use a trick to store the condition of empty arg 1 on entry 
      % point of the method, indicating a registering mode for the
      % call change(o,'Config',mode) (only relevant for such call)
      
   [gamma,oo] = manage(o,varargin,@Config,@Overlays,@Bias,@Signal,@Labels);
   oo = gamma(oo);
end

%==========================================================================
% Local Functions
%==========================================================================

function o = Config(o)                 % Change Config                 
%
% CONFIG   Handler for a call: change(o,'config')
%
% Description of Initialisation Process
% =====================================
%
% 1) Registration (see play/study/Register) 
%       o = play                       % let object o be of class PLAY
%       o = Config(type(o,'trigo'));
%    which leads to:
%       change(o,'config',o);          % arg(o,1) = []
%    We have:
%       active type: ''
%       callback list: {''}
%       configuring callbacks: none
%       => cblist = {'study','Config',[]}
%    Intended action:
%       => active(o,cblist)            % conditional registering
%    Ends up in conditional change of control structure
%       => control(o,{'config.play.trigo'},cblist)
%    Mind
%       no change of View>Signal menu
%       
% 2) Active Type Change Initiated by Graph
%       o = play                       % let object be of class play
%       Graph(o)                       % called of play/study/Study2
%
   if opt(o,'emptyarg1')               % if registering ... 
      config(o,{o});                   % conditional config registering
      event(o,'Config');               % refresh config menu
   else
      config(o,o);                     % change configuration
      event(o,'Signal');
      refresh(o);                      % refresh screen
   end
end
function o = Overlays(o)               % Change Overlay Mode           
   value = arg(o,1);                   % get overlay mode value
   setting(o,'style.overlays',value);  % change overlay's style setting
   event(o,'Style');                   % execute 'Style' event queue
end
function o = Bias(o)                   % Change Bias Mode              
   value = arg(o,1);                   % get bias mode value
   setting(o,'mode.bias',value);       % change bias mode setting
   event(o,'Bias');                    % execute 'bias' event queue
end
function o = Signal(o)                 % Change Signal                 
   atype = active(o);                  % get active type
   if ~isempty(atype)
      oo = type(o,atype);              % make an active typed object
      mode = subplot(oo,'Signal');     % get signal mode
      setting(o,'mode.signal',mode);
      tag = 'mode.signal';
      try
         choice(o,tag,mode);           % change choice
      catch
         'dont worry, be happy!';
      end
   end
end
function o = Labels(o)                 % Change Labels                 
   value = arg(o,1);                   % get bias value
   setting(o,'style.labels',value);    % change bias setting
   event(o,'Style');                   % execute 'style' event queue
end

