function path = articles(o,path)       % Persistent Article Directory          
%
% ARTICLES  Persistent storage of articles directory
%
%           articles(cut,path)         % store persistent directory path
%           path = articles(cut)       % recall persistent directory path
%
%        See also: CUT, ARTICLE
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

