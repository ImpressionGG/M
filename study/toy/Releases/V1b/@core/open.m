function out = open(obj,filepath)
%
% OPEN   Open a .MAT file. This is the combination of LOAD and LAUNCH.
%
%   Syntax
%
%       obj = open(obj,filepath)         % open object from file path
%       obj = open(obj,'e:/tmp/obj.mat') % open object from e:/tmp/obj.mat
%       obj = open(obj,'./obj.mat')      % open object from ./obj.mat
%       obj = open(obj,'obj.mat')        % open object from c:/data/obj.mat
%       obj = open(obj,'obj')            % open object from c:/data/obj.mat
%       obj = open(obj,'obj.m')          % open object from c:/data/obj.m
%
%    The provided file path will be checked for proper file extension. If
%    file extension is not '.mat' then LOAD will ask if the non-'.MAT'
%    option was chosen intentionally.
%
%    2) Empty File Path Provided (as 2nd arg)
%
%       obj = open(obj,'')               % opening file dialog for load
%
%    A file dialog will be forced to open. Object will be loaded from speci-
%    fied file path. 
%
%    3) single argument provided
%
%       obj = open(obj)                  % open according to options
%
%    Options option(obj,'directory') and option(obj,'filename')
%    are used to compose a proper file path. If the directory is empty the
%    current directory will be used. If filename is empty then a file
%    dialog will be opened to select a file path.
%
%    If a file dialog is terminated with CANCEL then function SAVE will be
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
%    See also: CORE, SAVE, LOAD, LAUNCH
%
   if (nargin == 1)
      obj = load(obj);
   elseif (nargin == 2)
      obj = load(obj,filepath);
   end
   
   if ~isempty(obj)
      directory = option(obj,'directory');
      filename  = option(obj,'filename');
      
      obj = option(obj,'directory',[],'filename',[]);   % clear
      
      launch(obj);      % launch menu shell
      refresh(obj);     % call refresh function
      
      obj = option(obj,'directory',directory);
      obj = option(obj,'filename',filename);
   end
   
      % set output arg if provided
      
   if (nargout > 0)
      out = obj;
   end
   return
end