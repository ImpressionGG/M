function o = shell(o,varargin)
% 
% SHELL   Toy Shell
%
%        Setup a menu shell and handle callbacks for TOY shell.
%
%             shell(toy)            % open menu and add demo menus
%             shell(toy,'Shell')    % add demo menus to existing menu
%             shell(toy,func)       % handle callbacks
%
%             o = gfo;              % retrieve o from menu's user data
%
%        Subdemo fuctions
%
%             toybasics             % basics demos
%             toyspin               % spin demos
%             entanglement          % entanglement demos
%             probability           % probability demos
%             toymodel              % toy model demos
%             contextual            % contextual dependency
%             toytest               % toy test routines
%
%        See also: TOY, CORE, MENU, GFO, SPINSPACE, PROBABILITY, TOYMODEL
%
   [cmd,o] = arguments(o,varargin,'Shell',{{'@','invoke'}});
   o = eval(cmd);
   return
end

%% Setup Shell

function o = Shell(o)   % Setup all standard menus
%
% SETUP    Setup menu
%
   vers = ['Version: toy@',version(toy),', core@',version(core)];
   title = either(get(o,'title'),'Quantum Toy Demo Shell');
   comment = either(get(o,'comment'),{'Working with toy objects',vers});

   o = set(o,'title',title,'comment',comment,'launch',mfilename);

   oo = menu(o,'Begin');             % begin menu setup
   oo = menu(o,'File');              % setup file roll down menu
   oo = toybasics(o,'Setup');        % setup Basics roll down menu
%    oo = toyspin(o,'Setup');          % setup Spin roll down menu
%    oo = entanglement(o,'Setup');     % setup Entanglement roll down menu
%    oo = probability(o,'Setup');      % setup Probability roll down menu
%    oo = toymodel(o,'Setup');         % setup Toy Models roll down menu
%    oo = contextual(o,'Setup');       % setup Contextual roll down menu
%    oo = toytest(o,'Setup');          % setup Test roll down menu
    oo = shell(o,'Info');             % setup info roll down
    oo = menu(o,'End');               % end menu setup
   
   trailer(o,'menu','Home');     % menu trailer will refresh
   return                     
end

%% Info Menu Setup
   
function o = Info(o)
%
% INFO   Setup Info roll down menu
%
   default('shell.assert',0);            % no assertions
   
   menu(o,'Info');                     % add standard Info rolldown menu
   ob1 = mitem(o,{'Info'});            % seek Info item
   
   menu(ob1,'Version');                  % add core version menu items
   ob2 = mitem(ob1,{'Version'});         % seek Version item
   Version(ob2);                         % add toy version menu items
   
   ob1 = mitem(o,{'Info'});            % seek Info item
   ob2 = mitem(ob1,'Help on Hot Keys',call,{'Help',1});
   return
end

%% Version Menu Items

function o = Version(o)
%
% VERSION   Add Version menu items
%
   ob1 = mitem(o,['Toy Toolbox: Version ',version(core)]);
   ob2 = mitem(ob1,'Display Release Notes','help toy/version');
   ob2 = mitem(ob1,'Edit Release Notes','edit toy/version');
   return
end

%% Help on Hot Keys

function o = Help(o)
%
% HELP
%
   switch arg(o,1)
      case 1
         view(o,'NavigateHelp');
   end
   return
end
