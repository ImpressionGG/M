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
%    Copyright(c): Bluenetics 2020 
%
%    see also: CORAZITO, DIRECTORY
%
