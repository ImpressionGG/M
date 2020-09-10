function demo(obj,varargin)
% 
% DEMO   Toy Demo
%
%        Setup demo menu & handle menu callbacks of user defined menu items
%        The function needs creation and setup of a chameo object:
%
%             demo(toy)             % open menu and add demo menus
%             demo(toy,'Setup')     % add demo menus to existing menu
%             demo(toy,func)        % handle callbacks
%
%             obj = gfo;               % retrieve obj from menu's user data
%
%        Subdemo fuctions
%
%             basics                % basics demos
%             spinspace             % spin demos
%             entanglement          % entanglement demos
%             probability           % probability demos
%             toymodel              % toy model demos
%             contextual            % contextual dependency
%
%        See also: TOY, CORE, MENU, GFO, SPINSPACE, PROBABILITY, TOYMODEL
%
   [cmd,obj,list,func] = dispatch(obj,varargin,{{'@','invoke'}},'Setup');

   eval(cmd);
   return
end

%==========================================================================
% Setup the Roll Down Menu
%==========================================================================

function Setup(obj)   % Setup all standard menus
%
% SETUP    Setup menu
%
%    Perform the following steps:
%    1) Setup title & comment (if you go with menu(obj,'Home') for refresh)
%    2) Setup the specific launch function to launch a new figure with menu
%    3) Open a figure with empty menu & setup the roll down menus
%    4) Setup a refresh function and refresh
%
   title = either(get(obj,'title'),'Quantum Toy Demo Shell');
   comment = either(get(obj,'comment'),{'Working with toy objects'});

   obj = set(obj,'title',title,'comment',comment,'launch',mfilename);

      % Never forget to setup the launch function
      
   obj = launch(obj,mfilename);  % use this mfile for launch function
                         
      % Launch function, title and comment are prepared now
      % Now setup the whole roll down menu
      
   menu(obj,'Empty');            % open figure & setup an empty menu
   menu(obj,'File');             % setup file roll down menu
   toybasics(obj,'Setup');       % setup Basics roll down menu
   spinspace(obj,'Setup');       % setup Spin roll down menu
   entanglement(obj,'Setup');    % setup Entanglement roll down menu
   probability(obj,'Setup');     % setup Probability roll down menu
   toymodel(obj,'Setup');        % setup Toy Models roll down menu
   contextual(obj,'Setup');      % setup Contextual roll down menu
   demo(obj,'Info');             % setup info roll down
   
      % setup key hit handler
      
   view(obj,'Setup');                  % setup keyhit handler
   view(obj,'Owner','Navigate')        % current view owner is 'Navigate'

      % Refresh figure and implicitely setup refresh function
      
   refresh(gfo);
   return                     
end

%==========================================================================
% Info Roll Down Menu
%==========================================================================
   
function Info(obj)
%
% INFO   Setup Info roll down menu
%
   default('shell.assert',0);            % no assertions
   
   menu(obj,'Info');                     % add standard Info rolldown menu
   ob1 = mitem(obj,{'Info'});            % seek Info item

   ob2 = mitem(ob1,'Help on Hot Keys',call,{'Help',1});
   return
end

%==========================================================================
% Help on Hot Keys
%==========================================================================

function Help(obj)
%
% HELP
%
   switch arg(obj,1)
      case 1
         view(obj,'NavigateHelp');
   end
   return
end
