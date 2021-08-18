%
% MSEEK   Seek a menu item
%
%    Seek either by a menu item path or by userdata. Second out arg is
%    setup for parent object.
%
%       o = mitem(o);                            % setup figure root
%       [oo,po] = mseek(o,{'#','Select'})        % find top label 'Select'
%       [oo,po] = mseek(o,{'Select'})            % find label 'Select'
%       [oo,po] = mseek(o,{'Select','Objects'})  % find label sequence
%
%       [oo,po] = mseek(o,userdata)              % non cell userdata
%
%       path = mseek(o)                          % get menu path
%
%    Example: assume that sub menu header is setup with 
%
%       function oo = Config(o)
%          oo = mhead(o,'Config',{},'$Config$');
%             :    :
%       end
%
%    then the following two lines can be used for menu rebuild:
%
%       [~,po] = mseek(o,'$Config$');            % seek parent of header
%       oo = Config(po);                         % rebuild menu
%
%    Note: if item not found then empty oo and po are returned!
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, MITEM, MHEAD
%
