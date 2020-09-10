function o = save(o,bag)
%
% SAVE   Save a bag of properties to .MAT file
%
%           o = save(caracow,bag)
%           o = save(caracow,pack(o))
%
%        Code lines: 13
%
%        See also: CARACOW, LOAD, DIRECTORY
%
   bull = carabull;                    % carabull object
   
   curdir = cd;                        % restore current directory
   if ~isempty(directory(bull))
      cd(directory(bull));
   end
   
   [file, dir] = uiputfile('.mat', 'Save .mat file');
   if ~isequal(file,0)
      directory(bull,dir);             % save to persistent directory path
      cso = server(bull,bag);          % create a Carabase server object
      save(cso,bag,[dir,file]);        % delegate save to carabase/save
   end
   
   cd(curdir);                         % restore current directory
end

