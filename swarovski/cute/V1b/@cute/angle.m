function [deg,phi] = angle(o,lage)
%
% ANGLE  For a CUT object of type ARTICLE return angle of a given
%        lage:
%
%           o = article(cut,'Kugel70')
%           deg = angle(o,lage)
%           deg = angle(o,5)
%
%           [deg,phi] = angle(cuo,fac);   % lage & facette angle
%           deg = angle(o)                % get table
%
%        See also: CUT, ARTICLE
%
   if (nargin == 1 && nargout < 2)
      deg = [data(o,'lage'); data(o,'angle')];
      return
   end

   if (nargin == 2 && nargout == 2)
      fac = lage;                       % correct var name
      [deg,phi] = LageFacette(o,fac);
      return
   end

   if (round(lage) ~= lage)
      error('lage (arg2 must be an integer!');
   end
   
   if isequal(lage,0)
      deg = 0;  phi = 0;
      return
   end
   
   idx = find(data(o,'lage')==lage);
   if (length(idx)~=1)
      deg = NaN;
      return
   end
   
   angles = data(o,'angle');
   if (idx <= 0 || idx > length(angles))
      deg = NaN;
      return
   end
   
   deg = angles(idx);
end

%==========================================================================
% Lage & Facette Angle
%==========================================================================

function [deg,phi] = LageFacette(o,fac)
%
   deg = NaN;  phi = NaN;             % by default
   lage = get(o,'lage');
   if isempty(lage)
      return
   end
   
   ao = article(o,get(o,'article'));
   if isempty(ao)
      return
   end
   
   deg = angle(ao,lage);
   tag = sprintf('facette%g',lage);
   facette = get(ao,tag);
   
   if (~isempty(facette) && fac >= 1 && fac <= length(facette))
      phi = facette(fac);
   end
end
