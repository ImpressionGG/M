function aspect(arat)
%
% ASPECT    Set data aspect ratio
%
%              aspect([1 1 1])
%              aspect           % same as above
%
%           See also: ROBO
%
   if (nargin < 1)
      arat = [1 1 1];
   end
   set(gca,'dataaspectratio',arat);

% eof