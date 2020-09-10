function out = load(obj,filepath)
%
% LOAD   Load a .MAT file
%
%    1) Non-empty File Path Provided (as 2nd arg)
%
%       obj = load(obj,filepath)           % save object to file path
%       obj = load(obj,'e:/tmp/obj.mat')   % save object to e:/tmp/obj.mat
%       obj = load(obj,'./obj.mat')        % save object to ./obj.mat
%       obj = load(obj,'obj.mat')          % save object to c:/data/obj.mat
%       obj = load(obj,'obj')              % save object to c:/data/obj.mat
%       obj = load(obj,'obj.m')            % save object to c:/data/obj.m
%
%    The provided file path will be checked for proper file extension. If
%    file extension is not '.mat' then LOAD will ask if the non-'.MAT'
%    option was chosen intentionally.
%
%    2) Empty File Path Provided (as 2nd arg)
%
%       obj = load(obj,'')                 % opening file dialog for load
%
%    A file dialog will be forced to open. Object will be loaded from speci-
%    fied file path. 
%
%    3) single argument provided
%
%       obj = load(obj)                    % load according to options
%
%    Options option(obj,'directory') and option(obj,'filename')
%    are used to compose a proper file path. If the directory is empty the
%    current directory will be used. If filename is empty then a file
%    dialog will be opened to select a file path.
%
%    If a file dialog is terminated with CANCEL then function LOAD will be
%    terminated with an empty output argument.
%
%
%    Core Sequence for Save and How to Load Object
%    =============================================
%
%    Sequence to load object to .MAT file:
%
%       filepath = upath(obj,directory,filename);     % construct filepath
%       load(filepath);                               % load -> obj
%
%    See also: CORE, SAVE, OPEN, LAUNCH
%
   out = obj;                  % save object as out
   
% dispatch calling syntax - there are 3 cases:
% 1) Two input args, 2nd arg non empty
% 2) Two input args, 2nd arg empty => open file dialog
% 3) One input arg => open file dialog if option(obj,'filename') is empty

   if (nargin == 2)            % case 1) or 2) - two input args
      if some(filepath)        % case 1) - nonempty filepath specified 
         [directory,name,ext] = fileparts(filepath);
         
         if isempty(directory)
            directory = either(option(obj,'directory'),cd);
         end
         
         if isempty(ext)
            ext = '.mat';
         end
         filename = [name,ext];
      else                     % case 2) - empty filepath
         directory = either(option(obj,'directory'),cd);
            
         [directory,filename] = FileDialog(obj,directory,'*.mat');
         if isempty(filename)
            out = [];
            return             % file dialog terminated with CANCEL
         end                   % otherwise directory and filepath are valid
      end
   elseif (nargin == 1)
      filename = option(obj,'filename');
      directory = option(obj,'directory');

      if isempty(directory)
         directory = cd;       % use current directory as a default
      end

         % replace any extension of filename by '.mat'
         
      if ~isempty(filename)
         [~,name,ext] = fileparts(filename);   % extract extension
         if ~strcmp(ext,'.mat')
            filename = [name,'.mat'];
         end
      end
      
      if isempty(filename)     % it follows the same procedure as in 2)
         [directory,filename] = FileDialog(obj,directory,'*.mat');
         if isempty(filename)
            out = [];
            return             % file dialog terminated with CANCEL
         end                   % otherwise directory and filepath are valid
      end
   else
      error('1 or 2 input args expected!');
   end

% Make a final consistency check for the extension

   [~,~,ext] = fileparts(filename);   % extract extension
   
   if ~strcmp(lower(ext),'.mat')
      txt = ['The extension provided for the filename ''',filename,...
             ''' has no .MAT extension! Do you want to continue?'];
      button = questdlg(txt,'Warning','OK','CANCEL','CANCEL');
      if ~strcmp(button,'OK')
         out = [];
         return
      end
   end

% Now we can go for the actual saving

   assert(some(directory));
   assert(some(filename));
   
   curdir = cd;                % save current directory
   try
      cd(directory);           % change to save directory
   catch
      cd(curdir);
      msgbox(['Save: Cannot change to directory: ',directory]);
      out = [];
      return
   end
   
% Now we have the right current directory for saving

   filepath = upath(obj,directory,filename);
   out = LoadObject(obj,filepath);
   
% Restore current directory   
   
   cd(curdir);
   
% finally update options with actual directory and file name

   if ~isempty(out)
      out = option(out,'directory',directory);
      out = option(out,'filename',filename);
   end
   return
end

%==========================================================================
% Load Object
%==========================================================================
   
function obj = LoadObject(obj,filepath)
%
% LOAD-OBJECT   Load object from .MAT file
%
   try
      load(filepath);    % that simple!
   catch
      msgbox(['Cannot load ''',filepath,'''']);
      obj = [];
   end
   return
end

%==========================================================================
% File Dialog
%==========================================================================
   
function [directory,filename] = FileDialog(obj,directory,filename)
%
% FILE-DIALOG   Open file dialog for loading object from .MAT file
%
   curdir = cd;                   % save current directory
   eval('cd(directory)','');
   
   while (1)
      [filename, directory] = uigetfile('*.mat', 'Load',filename);
      if some(filename)
         break
      end
   end

   if (filename == 0)             % user pressed cancel
      directory = '';
      filename = '';
   end
   
   cd(curdir);                    % restore current directory
   return
end   
   
