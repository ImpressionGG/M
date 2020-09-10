function value = default(name,value,dummy)
%
% DEFAULT   Provide a default setting for current figure. These
%           settings are stored as a structure in figure's user data. 
%         
%              default               % provide standard defaults
%              default('flag',1)     % provide default 1 for 'flag'
%
%           We can retrieve what initially has been provided as default:
%
%              value = default(name);   % get initial default setting
%
%           In general the names of the several settings can be chosen by
%           user definition. There are, however, frequently used conventions
%           for defult settings:
%
%              default('color',{'b','g','r','c','m','y','k'});  % color list for plotting
%              default('bullets',0);          % draw black bullets (0/1)
%              default('grid',0);             % grid off/on (0/1)
%
%           See also: SMART SETTING ADDON OPTION

   if (nargin >= 1)
      if isobject(name)
         fprintf(['*** Warning: the current usage of default() with an ',...
            'object as first arg will be obsolete in future!\n       ',...
            '      Change the default() call ''default(obj,arg,..)'' ',...
            'by removing the object argument!\n']);
         if (nargin == 1)
            value = default;                % shift 
         elseif (nargin == 2)
            value = default(value);         % shift name <- value
         elseif (nargin == 3)
            value = default(value,dummy);   % shift name <- value <- dummy
         else
            error('setting(): max 3 args expected for old style call');
         end
         return
      end
   end

% from here we have new style calling convention

   settings = get(gcf,'userdata');
   
   if (nargin == 0)
      defaults
   elseif (nargin == 1)
      def = defaults;
%       value = eval(['def.',name],'[]');
      if isfield(def,name),
         value=def.(name);
      else
         value=[];
      end
   elseif (nargin == 2)
%       try
%          value = eval(['settings.',name,';']);  % setting already existing?
%       catch
%          eval(['settings.',name,'=value;']);    % if not existing then set
%          set(gcf,'userdata',settings);          % refresh user data
%       end
      if isfield(settings,name)
         value=settings.(name);
      else
         settings.(name)=value;
         set(gcf,'userdata',settings);
      end
   else
      error('smart::default(): 0 or 2 args expected!');
   end 
   return

%==========================================================================
% Auxillary Functions
%==========================================================================

function out = defaults
%
% DEFAULTS   Provide Standard Defaults
%
   clist = {'b','g','r','c','m','y','k'};
   plist = {{''},{'',''},{'','',''}};
   slist = {{''},{'x','y'},{'x','y','z'}};
%    xscale = {1/60,'min'}; 
   
   def.az_el = [30 30];             % view angels
   def.baseline = '';               % no base line defined
   def.biasmode = 'absolute';       % bias: 'absolute','drift','deviation'
   def.bullets = 0;                 % draw black bullets (0/1)
   def.color = clist;               % color list for plotting
   def.direction = 1;               % next/previous direction
   def.dispmode = 'stream';         % display mode set to 'stream'
   def.filtmode = 'raw';            % set filter mode for raw data display
   def.filter = 6;                  % filter mode = 6 
   def.grid = 1;                    % grid off/on (0/1)
   def.ignore = 0;                  % number of points to be ignored
   def.menubar = 0;                 % standard menus off
   def.linewidth = 3;               % plot line width
   def.prefix = plist;              % prefix list for symbols & statistics
   def.scope = 1;                   % scope: number of subsequent selections
   def.select = 1;                  % selected substream
   def.subidx = [];                 % no sub index defined
   def.statistic = 0;               % show statistic in title (0/1)
   def.suffix = slist;              % suffix list for symbols & statistics
   def.view = 'sview';              % standard view angles 
   def.window = 50;                 % filter window width
   def.xscale = 1;                  % scale factor x, unit
   def.yscale = 1;                  % scale factor y, unit
   def.ascale = 1;                  % scale factor y, disp mode = 'absmm'
   def.xunit = '';                  % x unit
   def.yunit = '';                  % y unit
   def.limits = [];                 % y/z-axis limits: empty = autoscale
   
   if (nargout == 0)
      flds = fields(def);
      for i=1:length(flds),
         % default('prefix',default('prefix'));
%          cmd = ['default(''',flds{i},''',default(''',flds{i},'''));'];
%          eval(cmd);
         default(flds{i},default(flds{i}));
      end
   else
      out = def;
   end
   return
   
%eof   