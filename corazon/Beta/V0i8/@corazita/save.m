function o = save(o,bag,path)
%
% SAVE   Save a bag of properties to .MAT file
%
%           o = save(corazita,bag)
%           o = save(corazita,pack(o))
%
%           o = save(corazita,bag,path)
%           o = save(corazita,pack(o),path)
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZITA, LOAD, DIRECTORY
%
   bull = corazito;                    % corazito object
   
   curdir = cd;                        % restore current directory
   if ~isempty(directory(bull))
      cd(directory(bull));
   end
   
   if (nargin >= 3)
      [dir,file,ext] = fileparts(path);
      dir = [dir,'/'];
      file = [file,ext];
   else
      [file, dir] = uiputfile('object.mat', 'Save .mat file');
   end
   
   if ~isequal(file,0)
      directory(bull,dir);             % save to persistent directory path
      cso = server(bull,bag);          % create a Corleon server object
      save(cso,bag,[dir,file]);        % delegate save to corleon/save
   end
   
   cd(curdir);                         % restore current directory
end

