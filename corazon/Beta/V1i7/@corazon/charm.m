% 
% CHARM   Add a charm functionality to a menu item
%
%    The charm functionality allows to edit a double or character setting
%    The type (double or char) cannot be changed (only the value).
%
%    Example
%
%       setting(o,{'value'},1.2);      % provide default for value
%
%       o = mitem(o,'Simple');               % add menu item
%       oo = mitem(o,'Value',{},'value');    % add menu sub-item
%
%       charm(oo);                     % charm functionality (no refresh)
%       charm(oo,{@refresh});          % charm functionality (with refresh)
%       charm(oo,{});                  % same as above
%
%    Change a setting from command line & update charm display
%
%       charm(o,tag,value);            % change value from command line
%
%    Process CHARM callback:
%
%       charm(corazon,inf)             % process CHARM callback
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, MENU, MITEM, CHOICE, CHECK, DEFAULT
%
