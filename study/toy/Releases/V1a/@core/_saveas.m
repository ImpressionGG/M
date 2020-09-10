function saveas(obj,OBJ)
%
% SAVEAS    Open file dialog and save object to m-file as selected by user
%
%              obj = chameo(data)                % create SHELL object
%              saveas(obj,obj)  % save SHELL object (or derived) to m-file
%
%           Remark: first object is to dispatch into the 'saveas' method
%                   and is always of class shell. Second argument is the
%                   object to be save (by call: 'save(obj,filename)
%
%           See also: SHELL FILEMENUFCN
%
   filename = option(obj,'shell.filename');

   curdir = cd;             % save current directory
   try
      directory = option(obj,'shell.directory');
      if ~isempty(directory)
         eval('cd(directory)','');  % catch locally if does not work
      end
   
      newfile = '';
      while isempty(newfile)
         [newfile, newpath, typevalue] = uiputfile('*.m', 'Save As',filename);
      end

      if newfile == 0
         return;       % user pressed cancel
      end

         % make sure a reasonable extension is used

      [p,f,ext] = fileparts(newfile);
      if isempty(ext)
         newfile = [newfile,'.m'];
      end

      filename = fullfile(newpath,newfile);

      cd(newpath);
      setting('shell.directory',newpath);
      
      save(OBJ,filename);    % save object to be saved
   catch
   end
   eval('cd(curdir)','');   % restore current directory (be tolerant)
      
   return
   
%eof