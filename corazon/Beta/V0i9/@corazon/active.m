function typ = active(o,typ,cblist)         % Get/Set active type 
%
% ACTIVE   Get active type. The active type is determined by the value of
%          the control variable control(o,'active').
%
%             active(o,type);               % change active type
%             type = active(o)              % retrieve active type
%
%             active(o)                     % print active settings
%             active(o,oo)                  % make sure oo.type is active
%
%          Typical events which change the active type are:
%          1) object selection (change of current object - changes the
%             active object according to the type of the selected object.
%          2) calling GRAPH method, which changes the active type according
%             to the type of the object which is passed to the GRAPH method
%          3) Explicite call of change(o,'active',type) to change active
%             type according to the value passed in arg3.
%
%          Changing the active type using change(o,'active',type) will 
%          always cause a change of the View/Signal menu, while using
%          active(o,type) does only change the control variable setting,
%          but not change the menus.
%
%          Copyright(c): Bluenetics 2020 
%
%          See also: CORAZON, CHANGE, GRAPH, CONTROL
%

%
% One input arg and no output args
% active(o) % print active settings
%
   while (nargin == 1) && (nargout == 0)                               
      oo = o.either(pull(o),o);        % be tolerant if no shell
      atype = control(oo,'active');
      txt = o.either(atype,'''''');
      fprintf('   active type: %s\n',txt);
      if ~isempty(atype)
         oo = type(o,atype);
         type(oo);
      end
      return
   end
%   
% One input arg
% type = active(o) % retrieve active type
% type = active(o) % retrieve also signal mode
%
   while (nargin == 1)                                                 
      oo = o.either(pull(o),o);        % be tolerant if no shell
      typ = control(oo,{'active',''});
      return
   end
%
% Two input args and second arg is a string in alist and no out args
% active(o,{type}) % register sigmode
%
   while (nargin == 2) && iscell(typ) && nargout == 0                 
      error('*** bug!');
      cblist = typ;                    % arg2 is a cblist
      atype = active(o);
      tag = Tag(o,atype);
      control(o,tag,cblist);           % registering
      return
   end
%
% Two input args and second arg is an object
% active(o,oo) % make sure that oo.type is active
%
   while (nargin == 2) && isobject(typ)                               
      oo = typ;                        % arg2 is an object
      atype = active(o);
      verbose = control(pull(o),{'verbose',0});
      
      if (verbose >= 3)
         [func,file] = caller(o);
         fprintf('=> calling activate(o,oo) by: %s/%s\n',file,func);
      end
      if ~isequal(atype,oo.type)
         if (verbose >= 2)
            [func,file] = caller(o);
            fprintf('=> activate %s (called by: %s/%s)\n',oo.type,file,func);
         end
         active(oo,oo.type);
         event(oo,'config');           % update config menu
         %event(pull(o),'signal');     % e.g., change View>Signal menu
         event(oo,'signal');           % e.g., change View>Signal menu
         oo = opt(oo,'refresh',0);     % inhibit refreshing
      end
      return
   end
%
% Two input args and 1 out arg
% cblist = active(o,type) % get type specific cblist
%
   while (nargin == 2) && nargout == 1                                 
      error('*** bug!');
      tag = Tag(o,typ);
      cblist = control(o,tag);         % get registered cblist
      typ = cblist;                    % return cblist as arg1
      return
   end
%
% Two or 3 input args
% active(o,type) % change active type
%
   while (nargin == 2)                                
      control(o,'active',typ);         % change control setting
      return
   end
%
% Going beyond this point is an error
%
   error('bad calling syntax');
   
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function tag = Tag(o,type)             % Tag Composition               
   tag = ['config.',class(o),'.',type];
end

%==========================================================================
% Description of Activation Mechanism
%==========================================================================

function Description                   % Description of Mechanism      
%
% Explanation of the Mechanism
%
% 1) General Philosophy
% =====================
%
% a) Every plotting action is done with respect to a type specific confi-
%    guration. A configuration is a set of attributes which can be set or
%    retrieved by methods config, category and subplot.
%
% b) The configuration refered to can be implicite or explicite, and it is
%    emphasized that any implicite or explicite configuration is always 
%    type specific, usually refering to the type of a specific object. 
%
% c) In the case of an explicite configuration the explicite configuration
%    is always provided by the shell, and we use the terms 'shell provided
%    configuration' and 'explicite configuration' as a synonym. The attri-
%    butes of a shell provided configuration are looked up in the shell
%    settings 'configuration', 'category' and 'subplot' with respect to the
%    object's type. 
%    The shell provided configurations may or may not be complete with res-
%    pect to a given set of types, in the worst case no explicite configu-
%    ration at all may be provided by the shell. A shell provided configu-
%    ration may typically change in one of the following four ways:
%       (i) A shell provided configuration may be installed during menu 
%           setup in the phase of shell initialisation.
%       (ii) A shell provided configuration may be intentionally changed
%           by the user through selection a signal menu item. Such menu
%           item click invokes a re-configuring callback which usually
%           changes the (type specific) shell provided configuration and
%           rebuilds the Configuration and Signal Menu.
%       (iii) A shell provided configuration may be changed by either
%       inheriting the configuration from the objec's options or by providing
%       a default configuration during object paste if the pasted object's
%       type has not a related shell provided configuration.
%       (iv) a shell provided configuration may be changed from command
%       line, either using methods config, category and subplot, typically,
%       however, using method signal (which makes use of methods config,
%       category and subplot)
%
% d) In the case f an implicite configuration the configuration is either
%    inherited from the object's options 'config', 'category' and 'subplot',
%    or, f not provided, the implicite configuration is provided by a
%    default configuration procedure.
%
% 2) Menu Control
% ===============
%
% 1) The following menus may be used to control the shell provided
%    configuration settings:
%       a) View/Signal: allows to select different sets of shell provided
%          configurations, in order to select different signals of a
%          cordoba (or derived) object during plotting and analysis
%       b) View/Config: allows to view and change details of a shell
%          provided configuration
%
% 2) All graphics refering to signals of a cordoba (or derived) object 
%    generated by plotting functions (issued by the Plot menu), analysis 
%    functions (issued by the Analysis menu) and study functions (issued
%    by the Study menu) should make there signal selection according to
%    the shell provided configuration and the object's type! 
%
% 3) In addition there is an active type which determines the kind of
%    View/Signal menu being setup, ...
%#########################################
%
% 1) Active Type
% ==============
%
% 1a) there is always an active type, which can be empty or non-empty.
%
% 1b) a type is activated using the ACTIVE method. E.g. for activating
%     an object's type we use:
%
%     >> active(o,'mytype');           % change active type
%
% 1c) in addition to the definition of an active type we can also define
%     an active configuration callback. Such callback can be provided by
%     a third input arg to an activation call:
%
%     >> active(o,type,cblist)                     % in general
%     >> active(o,'mytype',{@shell,'Config','XY'}  %  specific
%
% 1d) active type and active configuration callback can be retrieved by
%     
%     >> [type,cblist] = active(o)     % get active type & config callback
%
% 1e) active type and actice configuration callback are stored in the 
%     control settings. Study the following example:
%
%     >> shell(cordoba);               % launch a shell
%     >> control(sho,'config',[]);     % clear existing config'd callbacks
%     >>
%     >> active(sho,'typ1',{@shell,'Config',Cfg1});
%     >> active(sho,'typ2',{@shell,'Config',Cfg2});
%     >>
%     >> control(sho,'active')
%     ans =
%     typ2
%     >> control(sho,'config')
%     ans = 
%        typ1: {[@shell]  'Config'  'Cfg1'}
%        typ2: {[@shell]  'Config'  'Cfg2'}
%
% 2) Actice Configuration
% =======================
%
% 2a) there is always an active configuration (which can be empty or
%     non-empty)
%
% 2b) the active configuration is stored in the following settings:
%     - setting(o,'config')
%     - setting(o,'category')
%     - setting(o,'subplot')
%
% 2c) an active configuration can be investigated by typing
%     >> config(sho)
%
% 2d) an active configuration can be set by invoking
%     >> shell(sho,'Config')
%
%
% 3) Signal Event Handling
% ========================
%
% 3a) The signal event handling leads to building up the proper View>Signal
%     menu (clicking subsequently on one of the Signal menu item leads then
%     to activation of a configuration). Such signal event is e.g. invoked
%     in cordoba/graph/Graph
%
%        function oo = Graph(o,mode)     % plot & put into clip board    
%           if ~isequal(active(o),o.type)
%              active(o,o.type);         % change active type
%              event(o,'signal');        % e.g., change View>Signal menu
%              change(o,'signal');       % update Signal menu
%           end
%           ...
%        end
%
% 3b) Invoking the signal event handler:
%
%        >> event(corazon,'signal')
%
% 3c) This will delegate event handling to the wrap function and is in fact
%     equivalent with the call
%
%        >> wrap(sho,'Signal')
%
% 3d) The wrapper will effectively call shell/Signal, thus invoking the
%     wrapper function is equivalent with calling the two statements:
%
%        >> oo = mseek(sho,{'View'})   % seek View menu item
%        >> shell(oo,'Signal')         % addView>Signal menu items 
%
% 3e) Depending on the active type the shell/Signal function builds up
%     a proper View>Signal menu. Also a plug point is provided to allow
%     activities of further View>Signal menu builders
%
%        function o = Signal(o)        % Signal Menu                   
%           oo = mhead(o,'Signal');    % definitely provide Signal header  
%           switch active(o);
%              case {'pln'}
%                 ooo = mitem(oo,'X/Y and P',{@SignalCb,'PlainXYP'});
%                 ooo = mitem(oo,'X and Y',{@SignalCb,'PlainXY'});
%              case {'smp'}
%                 ooo = mitem(oo,'All',{@SignalCb,'SimpleAll'});
%                 ooo = mitem(oo,'X/Y and P',{@SignalCb,'SimpleXYP'});
%                 ooo = mitem(oo,'UX and UY',{@SignalCb,'SimpleU'});
%           end
%           plugin(oo,'play/shell/Signal');   % plug point
%        end
%
end