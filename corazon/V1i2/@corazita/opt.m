%
% OPT   Get or set object options
%  
%    Object options are stored in object's work properties.
%  
%         opts = opt(o)                % get bag of options
%         opt(o,opts)                  % refresh all options
%
%      Get/set specific option setting
%
%         value = opt(o,'flag')        % get value of specific option
%         o = opt(o,'flag',1)          % set value of specific option
%
%      Conditional get/set option
%
%         value = opt(o,{'flag',0})    % get option or 0 (default) if empty
%         o = opt(o,{'flag'},0)        % set option only if empty
%
%      Copyright(c): Bluenetics 2020 
%
%      See also: CORAZITA, PROPERTY
%
