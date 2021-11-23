%
% MITEM   Add menu item
%
%    A uimenu item will be added with an implicite callback to 'call'.
%    The handle of the new created menu item is stored in the working
%    property work(o,'mitem').
%
%    Callbacks are always passed as calling list with the first list item
%    being a string (function name) or a function handle.
%
%       mitem(o)                       % display menu item info
%       bag = mitem(o);                % get menu item stuff
%       oo = mitem(o,'File');
%       ooo = mitem(oo,'Open',{@Open});
%       ooo = mitem(oo,'Save',{@Save},userdata);
%
%    Separator
%
%       mitem(o,'-');                  % activate separator for next item
%       mitem(o,'');                   % deactivate separator for next item
%
%    Get/set graphics handle
%
%       hdl = mitem(o,inf)             % get graphics handle
%       o = mitem(o,hdl)               % set graphics handle
%       o = mitem(o,figure(o))         % set up as a figure root
%
%    Choice functionality:
%
%       setting(o,{'view.color'},'b');
%
%       o = mitem(o,figure(o));        % set top level handle
%       oo = mitem(o,'View');
%       ooo = mitem(oo,'Color','view.color');
%       choice(ooo,{{'Red','r'},{'Blue','b'}}});   % no refresh
%
%    Alternatively
%
%       choice(ooo,{{'Red','r'},{'Blue','b'}}},{});   % with refresh
%
%    Get/Set menu item stuff
%
%       oo = mseek(o,{'#' 'Plot' 'Overview})
%       stuff = mitem(oo)              % get mitem stuff
%
%       stuff = {'Overview',{@plot 'MyOvw},1,'visible','on','enable','on'}
%       mitem(oo,stuff)                % set menu item stuff
% 
%          bag.label = 'Overview'
%          bag.callback = callback(o,{@Overview})
%          bag.userdata = []
%          bag.enable = 'on'
%          bag.visible = 'on'
%
%          mitem(o,bag)                % set menu stuff
%
%       Syntactic sugar for change of menu item attributes
%
%          mitem(o,{'Overview')        % change label
%          mitem(o,{'Overview',{@Overview},userdata})
%          mitem(o,{'Overview',{@Overview},userdata,'on','on'})
%
%       Example
%
%          oo = mseek(sho,{'#' 'Plot' 'Overview'}
%          mitem(oo,{'Magic',{@(o) disp(magic(3)) }})
%
%    Copyright (c): Bluenetics 2020 
%
%    See also: CORAZON, CHOICE, MSEEK, MHEAD
% 
