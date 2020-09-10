function o = article(o,name,dir)
%
% ARTICLE  Load an article into a given ID by name from a .art file.
%          Search path can be implicit (current directory) or explicite.
%          Any directory in search path with name '@Article' is also
%          considered for search.
%
%             o = article(cut,'Kugel70')     % use: dir = articles(cut)
%             o = article(cut,'Kugel70',dir)
%
%        See also: CUT, ANGLE
%
   if (nargin < 3)
      dir = articles(o);
   end

   path = [dir,'/',name,'.art'];
   if (exist(path) ~= 2)
      o = [];
   else
      o = read(o,'ReadGenDat',path);
   end
end

