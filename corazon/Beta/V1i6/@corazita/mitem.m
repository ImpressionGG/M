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
%       o = mitem(o);                  % set top level handle
%       oo = mitem(h,'File');
%       ooo = mitem(hh,'Open',{@Open});
%       ooo = mitem(hh,'Save',{@Save},userdata);
%
%    Get/set graphics handle
%
%       hdl = mitem(o,inf)             % get graphics handle
%       o = mitem(o,hdl)               % set graphics handle
%       o = mitem(o,gcf)               % set graphics root (figure)
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITA
% 
