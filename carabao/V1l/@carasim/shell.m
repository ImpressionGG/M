function oo = shell(o,varargin)        % CARASIM shell
   [gamma,o] = manage(o,varargin,@Shell,@Dynamic,@MotionCb,@DutyCb);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);                        % init object

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   oo = menu(o,'Edit');                % add Edit menu
   oo = Motion(o);                     % add Motion menu
   oo = Simulation(o);                 % add Simulation menu
   oo = menu(o,'Gallery');             % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = menu(o,'Figure');              % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o = dynamic(o,false);               % setup as a static shell
   o = launch(o,mfilename);            % setup launch function

   o = provide(o,'par.title','Carasim Shell');
   o = provide(o,'par.comment',{'Playing around with CARASIM objects'});
   o = refresh(o,{'menu','About'});    % provide refresh callback function
end
function list = Dynamic(o)             % List of Dynamic Menus         
   list = {'Motion'};
end

%==========================================================================
% File Menu
%==========================================================================

function oo = File(o)                  % File Menu                     
   oo = menu(o,'File');                % add File menu
end

%==========================================================================
% Motion Menu
%==========================================================================

function oo = Motion(o)                % Motion Menu                   
   setting(o,{'motion.smax'},100);
   setting(o,{'motion.vmax'},1000);
   setting(o,{'motion.amax'},10000);
   setting(o,{'motion.tj'},0.01);
   setting(o,{'motion.unit'},'mm');
   setting(o,{'motion.info'},'Motion Profile');
   
   oo = mhead(o,'Motion');             % add roll down header menu item
   ooo = mitem(oo,'Motion Plot',{@MotionCb});
   ooo = mitem(oo,'Duty Plot',{@DutyCb});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Stroke [mm]',{},'motion.smax');
   charm(ooo,{});
   ooo = mitem(oo,'Velocity [mm/s]',{},'motion.vmax');
   charm(ooo,{});
   ooo = mitem(oo,'Acceleration [mm/s]',{},'motion.amax');
   charm(ooo,{});
   ooo = mitem(oo,'Jerk Time [s]',{},'motion.tj');
   charm(ooo,{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Unit',{},'motion.unit');
   choice(ooo,{{'mm','mm'},{'°','°'}},{});
   ooo = mitem(oo,'Info',{},'motion.info');
   charm(ooo,{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Motion Jet',{@JetCb});
end
function oo = MotionCb(o)              % Motion Callback               
   refresh(o,inf);                     % use this callback for refresh
   oo = with(o,'motion');
   motion(oo);                         % forward to carasim.plot method
   shg
end
function oo = DutyCb(o)                % Duty Callback                 
   refresh(o,inf);                     % use this callback for refresh
   oo = with(o,'motion');
   duty(oo);                           % plot duty cycle
   shg
end
function oo = JetCb(o)                 % Motion Jet Callback           
   refresh(o,inf);                     % use this callback for refresh
   oo = with(o,'motion');
   motion(oo,inf);                     % motion jet
   shg
end

%==========================================================================
% Simulation Menu
%==========================================================================

function oo = Simulation(o)            % Simulation Menu               
   oo = simu(o,'Setup');               % add Simulation menu
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                     
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Carabao Class: Version ',version(carabao)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit carabao/version');
end
