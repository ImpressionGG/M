% 
% MENU   Package to provides building blocks for shell menu
%      
%           menu(o,locfunc)            % call local function 
%
%        Basic Menu Setup
%           oo = menu(o,'Begin');      % begin menu setup
%           oo = menu(o,'End');        % end menu setup
%
%        File Menu
%           oo = menu(o,'File');       % add standard File menu
%
%           oo = menu(o,'New');        % add New menu item
%           oo = menu(o,'Open');       % add Open menu item
%           oo = menu(o,'Save');       % add Save menu item
%           oo = menu(o,'Import',caption,cblist); % add Import menu item
%           oo = menu(o,'Export',caption,cblist); % add Export menu item
%           oo = menu(o,'Clone');      % add Clone menu item
%           oo = menu(o,'Rebuild');    % add Rebuild menu item
%           oo = menu(o,'CloseOther'); % add CloseOther menu item
%           oo = menu(o,'Close');      % add Close menu item
%           oo = menu(o,'Exit');       % add Exit menu item
%
%        Edit Menu
%           oo = menu(o,'Edit');       % add standard Edit menu
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZITA, SHELL
%
