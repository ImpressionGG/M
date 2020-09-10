function obj = translate(obj,arg2,arg3,arg4)
%
% TRANSLATE  Translation of options
%
%    Translates a current option setting to a required option setting.
%
%    1) General case:
%    ================
% 
%    Translate an option from a parent's other option
% 
%      obj = translate(obj,'filter',parent,'analyse.filter')
%      obj = translate(obj,'time',parent,'timing.time')
% 
%    This is the same as
% 
%      obj = option(obj,'filter',option(parent,'analyse.filter'))
%      obj = option(obj,'time',option(parent,'timing.time'))
% 
%    2) Parent and object are the same:
%    ==================================
% 
%      obj = translate(obj,'filter','analyse.filter')
%      obj = translate(obj,'time','timing.time')
% 
%    This is the same as
% 
%      obj = translate(obj,'filter',obj,'analyse.filter')
%      obj = translate(obj,'time',obj,'timing.time')
% 
%    3) Same option name, but object differing from parent
%    =====================================================
% 
%      obj = translate(obj,parent,'indent')
%      obj = translate(obj,parent,'trace.format')
% 
%    This is the same as
% 
%      obj = translate(obj,'indent',parent,'indent')
%      obj = translate(obj,'trace.format',parent,'trace.format')
% 
%    4) Syntactic Sugar #1
%    =====================
% 
%    Translate settings from a parent to a child which shall be
%    prepared for a select:
% 
%      obj = translate(obj,parent);  % syntactic sugar
% 
%         This is the same as the sequence
% 
%      obj = translate(obj,'timing',parent,'timing');
%      obj = translate(obj,'align',parent,'align');
%      obj = translate(obj,'filter',parent,'filter');
%      obj = timing(obj);
% 
%    prepared for a select:
% 
%      obj = translate(obj,parent);  % syntactic sugar
% 
%    5) Syntactic Sugar #2
%    =====================
% 
%    Translate options with a prefix to settings without prefix.
%    E.g. if we have
% 
%      option(obj,'select.section')
%      option(obj,'select.type')
% 
%    then the syntactic sugar statement
% 
%      obj = translate(obj,'select')
% 
%    has the same effect as the two statements:
% 
%      obj = translate(obj,'section',obj,'select.section)
%      obj = translate(obj,'type',obj,'select.type)
% 
%    See also: CORE, SETTING, OPTION
%

%    if (nargin < 4)
%       arg4 = arg2;                              % same - same option
%    end
   
   if (nargin == 2)                             % Syntactic Sugar #1 ?
      if (isobject(obj) && isobject(arg2))
         obj = translate(obj,'timing',arg2,'timing');
         obj = translate(obj,'align',arg2,'align');
         obj = translate(obj,'filter',arg2,'filter');
         obj = timing(obj);
      elseif (isobject(obj) && isa(arg2,'char'))
         tag = arg2;
         value = option(obj,tag);
         
         if ~isstruct(value)
            error('Cannot proceed with syntactic sugar!');
         end
         
         flds = fields(value);
         for (i=1:length(flds))
            dtag = flds{i};                  % destination tag
            stag = [tag,'.',dtag];           % source tag
            value = option(obj,stag);
            obj = option(obj,dtag,value);    % copy value
         end
      end
      return
   end

% OK - syntactic sugar check completed. Let's process the normal stuff

   if (nargin == 3)
      if isa(arg2,'char')    % translate(obj,'format','trace.format')
         obj = translate(obj,arg2,obj,arg3);
      elseif isobject(arg2)   % translate(obj,parent,'format')
         obj = translate(obj,arg3,arg2,arg3);
      else
         error('bad calling syntax!');
      end
   elseif (nargin == 4)
      optionname = arg2;
      parent = arg3;
      settingname = arg4;

      value = option(parent,settingname);   % get current option
      obj = option(obj,optionname,value);   % set target option value
   else
      error('max 4 input args allowed!');
   end
   return
   
%eof   