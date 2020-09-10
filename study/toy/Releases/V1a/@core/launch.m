function launch(obj,extension)
%
% LAUNCH   Open file dialog and launch CORE object from m-file
%
%    Syntax
%
%       launch(core)            % launch CORE object from m-file
%       launch(core,'.m')       % launch CORE object from m-file
%       launch(core,'.mat')     % launch CORE object from m-file
%
%    The provided object (arg1) has no special meaning and is 
%    only necessary for accessing the launch() method.
%
%    See also: CORE, IMPORT, SAVEAS
%
   extension = eval('extension','''.m''');   % default extension = '.m'
   
   filename = setting('shell.filename');
   idx = findstr(filename,'.log');
   if ~isempty(idx)
      filename(idx(1):end) = '';
      filename = [filename,extension];   % replace '.log' by '.m' or '.mat'
   end
   
      % next we have to make sure that filename has an extension. This is
      % because TCB objects always have a sub-directory with the same name 
      % as the m-file name, and uigetfile would automatically skip into the
      % sub-directory

   [directory,fname,ext] = fileparts(filename);
   if (isempty(ext))
      filename = [filename,extension];
   end

   curdir = cd;

   directory = option(obj,'shell.directory');
   
   if ~isempty(directory)
      eval('cd(directory)','');
   end

   newfile = '';
   while isempty(newfile)
      [newfile, newpath, typevalue] = uigetfile(['*',extension], 'Open',filename);
   end

   if newfile == 0
      return;       % user pressed cancel
   end
   
   [path,file,ext] = fileparts(newfile);

   if option(obj,'shell.debug')
      flaunch(newpath,file,ext);
   else
      try
         flaunch(newpath,file,ext);
      catch
         lerr = lasterror;    
         path = cd;  idx = find(path=='\');    path(idx) = 0*idx+'/';
         msgbox({'flaunch(): exception catched!',...
                 'Try to launch:','',['     ',filename],'',...
                 'current directory set temporarily to',...
                 '',['     ',path],'',lerr.message});
      end
   end
   cd(curdir);
   
   return
end   
   
%==========================================================================

function flaunch(path,filename,ext)
%
   tstart = clock;
   
   if ~isempty(path)
      cd(path);
      setting('shell.directory',path);
   end
   
   if strcmp(ext,'.m')
      obj = eval(filename);    % create object
   elseif strcmp(ext,'.mat')
      clear obj;
      load([filename,ext]);          % loaded object = obj
      if ~exist('obj')
         error(['could not load object from MAT file: ',filename]);
      end
   end
      
   obj = option(obj,'shell.directory',cd);
   obj = option(obj,'shell.filename',filename);
   pos = get(gcf,'position');

   clone = get(obj,'clone');
   if isempty(clone)
      clone = 'menu';
   end
   cmd = [clone,'(obj);'];
   eval(cmd);               % launch menu for newly created object
   set(gcf,'position',[pos(1)+20,pos(2)-20,pos(3:4)])
      
   return
end
