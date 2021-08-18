%
% MHEAD   Provide a menu header item
%
%    First the menu item is seeked. When found all its children are
%    deleted.
%
%       oo = mhead(o,'Objects');
%       oo = mhead(o,{'Select','Objects'});
%
%       oo = mhead(o,label,callback,userdata);
%
%    Example
%
%       function oo = Objects(o)
%          oo = mhead(o,'Objects','','select.current');
%       end
%
%       function oo = RefreshhObjects(o)
%          [~,po] = mseek(mitem(o),'select.current');
%          oo = Objects(po);
%       end
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, MITEM, MSEEK
%
