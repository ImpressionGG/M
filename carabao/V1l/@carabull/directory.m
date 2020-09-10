function path = directory(o,path)      % Persistent Directory          
%
% DIRECTORY   Persistent storage of current save/load directory
%
%           directory(carabull,path)   % store persistent directory path
%           path = directory(carabull) % recall persistent directory path
%
%        Code lines: 11
%
%        See also: CARABULL, FSELECT, LOAD, SAVE
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

