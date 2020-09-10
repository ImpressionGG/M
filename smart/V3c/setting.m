function value = setting(name,value,dummy)
%
% SETTING   Get or set figure/menu settings of current figure. These
%           settings are stored as a structure in figure's user data. 
%           First arg can be any SMART object, just to give access to
%           the method SETTING.
%         
%              value = setting('flag')      % get setting of 'flag' 
%              settings = setting           % get all settings (struct)
%
%              setting('flag',0)            % change value of 'flag' => 0
%              setting(settings)            % refresh all settings (struct)
%
%           See also: SMART GCFO DEFAULT OPTION ADDON

   if (nargin >= 1)
      if isobject(name)
          fprintf(['*** Warning: the current usage of setting with an ',...
             'object as first arg will be obsolete in future!\n       ',...
             '       Either change the setting call ''setting(obj,arg,..)'' ',...
             'by removing the object argument\n',...
             '             => ''setting(arg,..)''',...
             ' or check the alternative fix by a call to ''option()''!\n']);
         if (nargin == 1)
            value = setting;
         elseif (nargin == 2)
            value = setting(value);         % shift name <- value
         elseif (nargin == 3)
            value = setting(value,dummy);   % shift name <- value <- dummy
         else
            error('setting(): max 3 args expected for old style call');
         end
         return
      end
   end

% from here we only deal with new style calls

   if (nargin == 0)      % retrieve all settings (retrieve gcf's user data)
       
      if (nargout == 0)
         disp(get(gcf,'userdata'));
      else
         value = get(gcf,'userdata');
      end
      
   elseif (nargin == 1)   % two possibilities a) and b)! 
       
      if (isstruct(name))    % a) refresh all settings!
         set(gcf,'userdata',name);
      elseif (ischar(name))   % retrieve particular setting specified by name
         settings = get(gcf,'userdata');
%          value = eval(['settings.',name,';'],'[]');
         if isfield(settings,name),
           value=settings.(name);
         else
           value=[];
         end
      else
         error('arg2: struct or character string expected!');   
      end
      
   elseif (nargin == 2)
      
      settings = get(gcf,'userdata');
      settings.(name)=value; % eval(['settings.',name,'=value;']);
      
      profile(smart,'setting',+1);    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      set(gcf,'userdata',settings);
      profile(smart,'setting',-1);    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   else
      error('setting(): 0,1 or 2 args expected!');
   end
   return

%eof   