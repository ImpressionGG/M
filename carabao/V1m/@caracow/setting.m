function value = setting(o,tag,value)  
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
%      Code lines: 33
%
%      See also: CARACOW, SHELF, PROP
%
    fig = figure(o);                   % find object's figure handle
%
% Before arg processing we will check if windows are open. If not then
% we will return with empty return value
%
   try                                 % fig could be empty or invalid
      if isempty(fig)
%        fig = gcf(o);
         fig = gcf(carabull);
      end
      userdata = get(fig,'userdata');  % check whether it works
      if ~isempty(userdata) && ~isstruct(userdata)
         error('catch me!');           % non struct user data is an error
      end
   catch
      value = [];                      % ignore if no windows open
      return
   end      
%
% figure handle was good - proceed!
%
   cob = carabull;                     % work with the CARABULL shelf
   switch nargin
      case 1
         settings = shelf(cob,fig,'settings');
         if (nargout == 0)
            disp(settings);
         else
            value = settings;
         end
      case 2
         if ischar(tag)
            value = shelf(cob,fig,['settings.',tag]); % recall from shelf @ 'settings'
         elseif iscell(tag)
            defval = tag{2};  tag = tag{1};  
            value = setting(o,tag);
            if isempty(value)
               value = defval;
            end
         elseif isempty(tag)
            shelf(cob,fig,'settings',[]);     % clear all settings
         elseif isstruct(tag)
            shelf(cob,fig,'settings',tag);    % init settings with struct
         end
      case 3
         if iscell(tag)
            tag = tag{1};
            if isempty(setting(o,tag))
               shelf(cob,fig,['settings.',tag],value); % change setting @ tag
            end
         else
            shelf(cob,fig,['settings.',tag],value); % change setting @ tag
         end
      otherwise
         error('1,2 or 3 input args expected!');
   end
end

