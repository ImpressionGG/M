function phi = facette(o,fdx)
%
% FACETTE  For a CUT object return facette angle given by facette index
%
%           phi = facette(cuo,fdx);       % facette angle by facette index
%
%        See also: CUT, ARTICLE, ANGLE
%
   phi = NaN;                      % by default
   lage = get(o,'lage');
   if isempty(lage)
      return
   end
   
   tag = sprintf('facette%g',lage);
   facette = get(o,tag);
   
   if (nargin == 1)
      if isempty(facette)
         return
      end
      fdx = 1:length(facette);
   end
   
   for (i=1:length(fdx))
      if (~isempty(facette) && fdx(i) >= 1 && fdx(i) <= length(facette))
         phi(i) = facette(fdx(i));
      else
         phi(i) = NaN;
      end
   end
end
