%
% PLUGIN   Plugin manager method
%
%             list = plugin(o)         % get plugin list
%             plugin(o)                % print registered plugins
%
%             plugin(o,list)           % replace plugin list by arg2
%             plugin(o,{})             % clear plugin list
%
%             plugin(o,key,cblist)     % register plugin callback
%             plugin(o,key)            % provide plug point
%
%          Example 1: corazon/shell/Info provides a plugin point
%
%             function oo = Info(o)    % corazon/shell/Info function
%                oo = menu(o,'Info');  % add Info menu
%                key = 'corazon/menu/Info';
%                plugin(oo,key)        % provide plugin point
%             end
%
%          Example 2: a plugin function xyplot registers two plugin
%          menu items
%
%             function o = Register(o)
%                plugin(o,'espresso/shell/Plot','xyplot','Plot');
%                plugin(o,'corazon/menu/Info','xyplot','Info');
%             end
%
%          Copyright (c): Bluenetics 2020 
%
%          See also: CORAZON, SIMPLE, LEGACY
%
