%
% WRAP   Wrap a function in order to build entry points for event
%        handling.
%
%        Wrappers for local functions of SHELL method
%
%           oo = wrap(o,'Export')      % wrap Export menu
%           oo = wrap(o,'Signal')      % wrap Signal menu
%           oo = wrap(o,'Plot')        % wrap Analysis menu
%           oo = wrap(o,'Analysis')    % wrap Analysis menu
%
%        Wrappers for local functions of MENU method
%
%           oo = wrap(o,'Config')      % wrap Config menu
%           oo = wrap(o,'Objects')     % wrap Objects menu
%           oo = wrap(o,'Basket')      % wrap Basket menu
%           oo = wrap(o,'Bias')        % wrap Bias menu
%           oo = wrap(o,'Style')       % wrap Style menu
%           oo = wrap(o,'Scale')       % wrap Scale menu
%
%        Wrapper functions implement an additional layer which act as 
%        event registration layers and event handler enntry points.
%        Wrapper functions call usually the shell method for menu build
%        or menu rebuild.
%
%        Overview: Wrapper functions, driven by which events
%
%           wrap(o,'Export')   <=    event 'Select'
%           wrap(o,'Signal')   <=    event 'Select', 'Signal'
%           wrap(o,'Plot')     <=    event 'Select', 'Plot'
%           wrap(o,'Analysis') <=    event 'Select', 'Plot'
%           wrap(o,'Config')   <=    event 'Select', 'Config'
%           wrap(o,'Objects')  <=    event 'Select'
%           wrap(o,'Basket')   <=    event 'Select'
%           wrap(o,'Facette')  <=    event 'Select'
%           wrap(o,'Bias')     <=    event 'Bias'
%           wrap(o,'Style')    <=    event 'Style'
%           wrap(o,'Scale')    <=    event 'Scale'
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZON, SHELL, MENU, EVENT
%
