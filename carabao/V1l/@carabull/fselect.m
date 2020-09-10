function [file,dir] = fselect(o,mode,path,caption)
%
% FSELECT   File selection dialog
%
%    Open a file selection dialog
%
%       [file,dir] = fselect(o,mode,filename)
%       [file,dir] = fselect(o,mode,filename,caption)
%
%    Examples
%       [file,dir] = fselect(o,'r','*.txt')      % read .txt file
%       [files,dir] = fselect(o,'m','*.txt')     % multi read .txt file
%       [file,dir] = fselect(o,'w','test.txt')   % write to test.txt
%       [files,dir] = fselect(o,'i','*.log')     % import file(s)
%       [file,dir] = fselect(o,'e','data.log')   % export file(s)
%       [file,dir] = fselect(o,'o','*.mat')      % open .mat file
%       [file,dir] = fselect(o,'s','*.mat')      % save .mat file
%       [file,dir] = fselect(o,'d','')           % select directory
%
%    Note: file is a character string and files is a cell array.
%    Note: isempty(file) and isempty(dir) when user cancels dialog
%
%    see also: CARABULL, DIRECTORY
%
   switch mode
      case 'r'                         % read file
         operation = 'read';
         text = 'Read file'; 
      case 'm'                         % multi read file(s)
         operation = 'multiread';
         text = 'Read file(s)'; 
      case 'w'                         % write file
         operation = 'write';
         text = 'Write file'; 
      case 'i'                         % import file(s)
         operation = 'multiread';
         text = 'Import file(s)'; 
      case 'e'                         % export file
         operation = 'write';
         text = 'Export file'; 
      case 'o'                         % open file
         operation = 'read';
         text = 'Open file'; 
      case 's'                         % save file
         operation = 'write';
         text = 'Save file'; 
      case 'd'                         % select directory
         operation = 'directory';
         text = 'Select directory'; 
      otherwise
         error('bad mode!');
   end      
         
   if (nargin < 4)                     % missing caption
      caption = text;                  % use default text for caption
   end
   
      % open the dialog
      
   curdir = cd;                        % save current directory
   try                                 % directory change might crash
      cd(directory(o));                % change to persistant directory
   catch
   end
   
   for (i=1:length(path))
      if any(path(i)==':|')
         path(i) = '-';                % substitute unallowed characters
      end
   end
   
   switch operation
      case 'read'
         [file, dir] = uigetfile(path,caption);
      case 'multiread'
         [file, dir] = uigetfile(path,caption,'MultiSelect','on');
         if ischar(file)
            file = {file};
         end
      case 'write'
         [file, dir] = uiputfile(path,caption);
      case 'directory'
         dir = uigetdir(path,caption);
         file = dir;
   end
   cd(curdir);                         % restore directory
   
   if isequal(file,0)
      file = {};  dir = '';
   else
      directory(o,dir);                % refresh persistent directory
   end
end   
