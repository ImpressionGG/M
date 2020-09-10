function path = filedialog   % select a log file (v1a/filedialog.m)
%
% FILEDIALOG   Dialog to select data log file: path = filedialog
%
   [file, dir] = uigetfile('*.log', 'Open .log file');
   if isequal(file,0)
      path = '';
   else
      path = [dir,file];
   end
end
