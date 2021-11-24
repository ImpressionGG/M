%
% VAR   Get or set object variable settings
%  
%    Object variables are stored in object's work properties.
%  
%         vars = var(o)                % get work variable settings
%         var(o,vars)                  % refresh all variable settings
%
%      Set/get specific variable setting
%
%         value = var(o,'flag')        % get value of specific setting
%         value = var(o,{'flag',0})    % get with default value (if empty)
%
%         o = var(o,'flag',1)          % set value of specific setting
%         o = var(o,{'date'},now)      % set only if empty
%
%      Multiple Get:
%
%         [A,B,C] = var(o,'A,B,C');         % direct get
%         [A,B,C] = var(o,{'A,B,C',A,B,C}); % conditional get
%
%      Multiple Set:
%
%         o = var(o,'A,B,C',A,B,C);         % direct set
%         o = var(o,{'A,B,C'},A,B,C);       % conditional set
%
%      Example: easy access
%
%         o = set(o,'system','A,B,C',magic (2),ones(2,1),ones(1,2))
%         oo = var(o,get(o,'system'))
%         [A,B,C] = var(oo,'A,B,C')
%
%      Copyright(c): Bluenetics 2020 
%
%      See also: CORAZITA, PROPERTY
%
