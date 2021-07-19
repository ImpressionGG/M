function obfuscate(tbox,version,class)
%
% OBFUSCATE   Obfuscate a directory, i.e, create *.p files in addition to
%             *.m files.
%
%                obfuscate(path,exceptions)
%                obfuscate(path,{'cache','call','id','menu'})
%
%                obfuscate corazon V1i2 @corazito
%
%             See also: pcode
%
   if (nargin == 2)
      dir = tbox;
      exceptions = version;
      
      fprintf('obfuscating directory %s\n',dir);
      pcode(dir,'-inplace');
      Convert(dir,exceptions);
      return
   end

   if (class(1) == '@')
      constructor = class(2:end);
   else
      error('no class directory (arg3)');
   end
   
   dir = [mhome,'/',tbox,'/',version,'/',class];
   path = [dir,'/',constructor,'.m'];
   
   if (exist(path) ~= 2)
      error(['constructor not found (',path,')']);
   end
   
   fprintf('obfuscating %s/%s/%s directory (%s)\n',tbox,version,class,dir);
   
      % actual obfuscating ...
      
   pcode(dir,'-inplace');
end

%==========================================================================
% Convert All M-Files to Comment Files 
%==========================================================================

function Convert(directory,exceptions)
   files = dir([directory,'/*.m']);
   if ~iscell(exceptions)
      error('exceptions (arg2) must be a list of strings');
   end
   
   for (i=1:length(files))
      file = files(i).name;
      folder = files(i).folder;
      isdir = files(i).isdir;
      
      if ( ~isdir )
         path = [folder,'/',file];
         Reduce(path);
      end
   end
end

%==========================================================================
% Reduce M-File to Comment File 
%==========================================================================

function Reduce(path)
   list = {};
   
   fid = fopen(path,'r');
   if isequal(fid,-1)
      error(sprintf('cannot open M-file (%s)',path));
   end
   
   state = 0;
   while (1)
      line = fgetl(fid);
      if isequal(line,-1)
         break;                        % we are done
      end
      
      switch (state)
         case 0
            if (~isempty(line) && line(1) == '%')
               state = 1;
               list{end+1} = line;
            end
         case 1
            if (~isempty(line) && line(1) == '%')
               list{end+1} = line;
            else
               break                   % we are done
            end
      end
   end
   fclose(fid);
   
      % now all commen lines are contained in list
      
   delete(path);                       % delete M-file
   
   fid = fopen(path,'w');
   for (i=1:length(list))
      fprintf(fid,'%s\n',list{i});
   end
   fclose(fid);
end

%==========================================================================
% Helper
%==========================================================================

function Corazon
%
   list = {'cache','call','id','menu','shell','version','with'};
end

function file = Exception(file,exceptions)
   name = file;
   if (length(name) > 2 && name(end-1) == '.' && name(end) == 'm')
      name = name(1:end-2);
   end
   
end