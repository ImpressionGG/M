% 
% CHOICE   Add a choice functionality to a menu item
%
%    Compact setup of choice rolldown menus based on lists like
%    {{'Red','r'},{'Blue','b'},{'Green','g'}} or numerical vectors
%    like 1:5, [1 2 5 10] or [0:0.1:0.9, 1:5]. CHOICE always refers to 
%    a setting which has to be refered in the parent item of the rolldown
%    menu.
%
%       setting(o,{'color'},'r');           % provide default for color
%
%       o = mhead(corazon,'Simple');        % add menu header item
%       oo = mitem(o,'Color','','color');   % add menu item
%
%       choice(oo,{{'Red','r'},{'Blue','b'}});          % no refresh
%       choice(oo,{{'Red','r'},{'Blue','b'}},'');       % default refresh
%       choice(oo,{{'Off',0},{'On',1}},{@refresh});     % user refresh
%       
%       choice(oo,1:5);                     % no refresh
%       choice(oo,1:5,{});                  % default refresh
%       choice(oo,1:5,'refresh(corazon)');  % user refresh
%
%       choice(oo,{1:5},{});                % default refresh
%       choice(oo,{{'Auto',[]},1:5},{});    % default refresh
%       choice(oo,{{'Auto',[]},{},1:5},{}); % default refresh
%
%    Change a setting from command line & update check mark
%
%       choice(o,tag,value);            % change value from command line
%
%    Example 1:
%       setting(o,{'color'},'r');             % set default for color
%       oo = mitem(o,'Color','','color');     % add menu item
%       choice(oo,{{'Red','r'},{'Blue','b'}},{});   % default refresh
%
%    Example 2:
%       setting(o,{'level'},1);               % set default level
%       oo = mitem(o,'Level','','level');     % add menu item
%       choice(oo,[0,1,2,3],{});              % default refresh
%
%    Example 3: choice list contains a separator ({})
%       setting(o,{'class'},'*');             % set default class
%       choices = {{'all','*'},{},{'ball','b'},{'cube','c'}};
%       oo = mitem(o,'Classes','','class');   % add menu item
%       choice(oo,choices,{});                % default refresh
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: SHELL, MENU, MITEM, CHECK, CHARM, SETTING
%
