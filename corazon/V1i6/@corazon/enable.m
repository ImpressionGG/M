%
% ENABLE   Enable or disable menu item
%
%             oo = mitem(o,'Menu Item')   % create menu item
%
%             enable(oo,1)                % enable menu item
%             enable(oo,0)                % disable menu item
%
%          Enable if current object matches type list
%
%             enabled = o.is(type(o),{'weird','ball'})
%             enable(oo,enabled)
%
%          Enable if one basket object matches type list
%
%             enable(oo,basket(o),{'weird','ball'})
%
%          Copyright(c): Bluenetics 2020 
%
%          See also: CORAZON, MITEM, VISIBLE
%
