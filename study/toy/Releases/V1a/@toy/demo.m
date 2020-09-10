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
% User Defined Menu Setup
%==========================================================================

function obj = LaunchMenu(obj)      % only called for stand-alone menu
%
% LaunchMenu   Add object info and launch menu
%
   title = 'toy Demo Shell';
   comment = {'Working with toy objects'
             };

   obj = set(obj,'title',title,'comment',comment,'menu',{'file'});
   menu(obj);                          % open menu
   return
end

%==========================================================================
% Setup the Roll Down Menu
%==========================================================================

function Setup(obj)
%
% SETUP       Setup the roll down menu for Alastair
%
   obj = LaunchMenu(obj);

   toybasics(obj,'Setup');             % setup Basics roll down menu
   spinspace(obj,'Setup');             % setup Spin roll down menu
   probability(obj,'Setup');           % setup Probability roll down menu
   toymodel(obj,'Setup');              % setup Toy Models roll down menu
   contextual(obj,'Setup');            % setup Contextual roll down menu
   InfoRollDown(obj);                  % setup info roll down
   
      % setup key hit handler
      
   view(obj,'Setup');                  % setup keyhit handler
   view(obj,'Owner','Navigate')        % current view owner is 'Navigate'

   return
end

%==========================================================================
% Info Roll Down Menu
%==========================================================================
   
function InfoRollDown(obj)
%
% SETUP Setup roll down menu
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);

   men = mount(obj,'<main>',LB,'Info');

   sub = uimenu(men,LB,'Help on Hot Keys',CB,call('Info'),UD,1);
   
   return
end

function Info(obj)
%
% INFO
%
   switch arg(obj,1)
      case 1
         view(obj,'NavigateHelp');
   end
   return
end
