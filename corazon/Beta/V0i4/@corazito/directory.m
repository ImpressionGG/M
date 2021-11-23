function path = directory(o,path)      % Persistent Directory          
%
% DIRECTORY   Persistent storage of current save/load directory
%
%           directory(corazito,path)   % store persistent directory path
%           path = directory(corazito) % recall persistent directory path
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZITO, FSELECT, LOAD, SAVE
%
   persistent directory
   if (nargin == 1)
      path = directory;
      if isempty(path)
         path = cd;                    % current directory
      end
   else
      directory = path;
   end
end

