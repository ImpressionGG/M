% 
% CHECK   Add a check functionality to a menu item
%
%    Example
%
%       setting(o,{'bullets'},1);      % provide default for bullets
%
%       o = mitem(o,'Simple');                   % add menu item
%       oo = mitem(o,'Bullets',{},'bullets');    % add menu sub-item
%
%       check(oo);                     % check functionality (no refresh)
%       check(oo,'refresh(corazon)');  % check functionality (with refresh)
%       check(oo,'');                  % same as above
%
%    Change a setting from command line & update check mark
%
%       check(o,tag,value);            % change value from command line
%
%    Process CHECK callback:
%
%       check(corazon,inf)             % process CHECK callback
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, MENU, MITEM, CHOICE, CHARM, SETTING
%
