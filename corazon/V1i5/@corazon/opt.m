%
% OPT   Get or set object options. Method corazon/opt is an extension of
%       method caracow/opt to support multiple get/set syntax.
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
%      Multiple get
%
%         [a,b,c] = opt(o,'a','b','c')
%         [a,b,c] = opt(o,'a,b,c')
%         [a,b,c] = opt(o,{'a',1},{'b',pi},{'c',NaN})
%         [a,b,c] = opt(o,{'a,b,c', 1,pi,NaN})
%
%      Multiple set
%
%         o = opt(o,'a',1, 'b',pi, 'c',NaN)
%         o = opt(o,'a,b,c', 1,pi,NaN)
%         o = opt(o,{'a'},1, {'b'},pi, {'c'},NaN})
%         o = opt(o,{'a,b,c'}, 1,pi,NaN)
%
%      See also: CORAZON, PROPERTY
%
