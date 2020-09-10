function o = article(o,name,dir)
%
% ARTICLE  Load article data with given ID from a .art file into object.
%          Search path can be implicit (current directory) or explicite.
%          Any directory in search path with name '@Article' is also
%          considered for search.
%
%             o = article(cute,'Kugel70')     % use: dir = articles(cut)
%             o = article(cute,'Kugel70',dir)
%
%        See also: CUTE, ANGLE
%
   if (nargin < 3)
      dir = articles(o);
   end

   path = [dir,'/',name,'.art'];
   if (exist(path) ~= 2)
      o = [];
   else
      o = opt(o,'progress',false);     % don't show progress bar
      o = read(o,'ReadGenDat',path);
   end
end

