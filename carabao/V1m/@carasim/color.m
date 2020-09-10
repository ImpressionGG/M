function col = color(o)
%
% COLOR   Get RGB color of CARASIM object
%
%            col = color(o)
%
%         See also: CARASIM
%
   col = getp(o,'color');              % get color property
   col = carabao.color(col);           % convert to RGB
end
