%
% SETTING   Get or set figure/menu settings
%  
%      These settings are stored as a structure in figure's user data. Note
%      that there are public and private settings. 
%  
%         settings = setting(o)        % get settings
%         setting(o,settings)          % refresh all settings
%
%      Set/get specific setting
%
%         value = setting(o,'flag')    % get value of specific setting
%         value = setting(o,{'flag',0})% get value, get default if empty
%
%         setting(o,'flag',1)          % set value of specific setting
%         setting(o,{'flag'},0)        % conditional setting (if empty)
%
%      Copyright(c): Bluenetics 2020 
%
%      See also: CORAZITA, SHELF, PROP
%
