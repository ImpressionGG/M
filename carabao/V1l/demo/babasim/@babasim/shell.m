function oo = shell(o,varargin)        % BABASIM shell
   [gamma,o] = manage(o,varargin,@Shell,@Register,@Root,@Test);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);                        % init object

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   %oo = shell(o,'Edit');              % add Edit menu
   %oo = shell(o,'View');              % add View menu
   %oo = shell(o,'Select');            % add Select menu
   %oo = shell(o,'Plot');              % add Plot menu
   %oo = wrap(o,'Analysis');           % add Analysis menu (wrapped)
   %oo = shell(o,'Plugin');            % add Plugin menu
   oo = shell(o,'Root');               % add Root menu
   oo = shell(o,'Test');               % add Test menu
   %oo = shell(o,'Gallery');           % add Gallery menu
   oo = shell(o,'Info');               % add Info menu
   %oo = shell(o,'Figure');            % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o = dynamic(o,false);               % setup as a non-dynamic shell
   o = launch(o,mfilename);            % setup launch function

   o = set(o,{'title'},'Babasim Shell');
   o = set(o,{'comment'},{'Playing around with BABASIM objects'});
   o = refresh(o,{'shell','Register'});% provide refresh callback function
end
function o = Register(o)               % Register Plugins              
   refresh(o,{'menu','About'});        % provide refresh callback function
   message(o,'Installing plugins ...');
   sample(o,'Register');               % register SAMPLE plugin
   basis(o,'Register');                % register BASIS plugin
   kefalon(o);                         % register kefalon plugin
   %pbi(o,'Register');                 % register PBI plugin
   rebuild(o);
end

%==========================================================================
% File Menu
%==========================================================================

function oo = File(o)
   oo = shell(o,'File');
   ooo = mseek(oo,{'#','File','New'});
   set(mitem(ooo,inf),'visible','off');
   ooo = mseek(oo,{'#','File','Import'});
   set(mitem(ooo,inf),'visible','off');
   ooo = mseek(oo,{'#','File','Export'});
   set(mitem(ooo,inf),'visible','off');
   ooo = mseek(oo,{'#','File','Tools'});
   set(mitem(ooo,inf),'visible','off');
end

%==========================================================================
% Root Menu
%==========================================================================

function oo = Root(o)                  % Root Menu                 
   oo = mhead(o,'Root');               % add roll down header menu item
   plugin(oo,'babasim/shell/Root');
end

%==========================================================================
% Logging Menu
%==========================================================================

function oo = Test(o)                  % Logging Menu                 
   oo = mhead(o,'Test');               % add roll down header menu item
   plugin(oo,'babasim/shell/Test');
end

