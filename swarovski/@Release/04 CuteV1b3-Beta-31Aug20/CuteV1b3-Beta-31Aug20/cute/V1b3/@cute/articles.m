function oo = articles(o,path)       % Persistent Article Directory          
%
% ARTICLES  Persistent storage of articles directory
%
%           articles(cute,path)       % store persistent directory path
%           path = articles(cute)     % recall persistent directory path
%           articles(cute)            % show article path & available art's 
%
%        Copyright: Bluenetics 2020
%
%        See also: CUTE, ARTICLE
%
   persistent directory
   if (nargin == 1)
      path = directory;
      if isempty(path)
         path = cd;                    % current directory
      end
      
      if (nargout > 0)
         oo = path;
      else
         List(o,path);
      end
   else
      directory = path;
   end
end

%==========================================================================
% List Articles
%==========================================================================

function List(o,path)
   fprintf('Article Directory:\n   path:\n      %s\n',path);
   fprintf('   available article data:\n');
   
   items = dir(path);
   for (i=1:length(items))
      name = items(i).name;
      [folder,file,ext] = fileparts(name);
      if isequal(ext,'.art')
         fprintf('      %s\n',file);
      end
   end
end