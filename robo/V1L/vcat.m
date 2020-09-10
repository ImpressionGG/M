function V = vcat(V0,V1,V2,V3,V4,V5,V6,V7,V8,V9)
%
% VCAT      Vector concatenation (separated by NANs)
%
%              V = vcat(V1,V2)
%              V = vcat(V1,V2,V3)
%              V = vcat(V1,V2,V3)
%
%           See also: ROBO, VPLT, VLETTER
%
   if (nargin == 1)
      sep = NaN * ones(size(V0(:,1)));
   elseif (nargin > 1)
      if isempty(V0)
         sep = NaN * ones(size(V1(:,1)));
      else
         sep = NaN * ones(size(V0(:,1)));
      end
   end

   if (nargin == 0)
      V = [];
   elseif (nargin == 1)
      V = V0;
   elseif (nargin == 2)
      if isempty(V0)
         V = V1;
      else
         V = [V0 sep V1];
      end
   elseif (nargin == 3)
      V = [V0 sep V1 sep V2];
   elseif (nargin == 4)
      V = [V0 sep V1 sep V2 sep V3];
   elseif (nargin == 5)
      V = [V0 sep V1 sep V2 sep V3 sep V4];
   elseif (nargin == 6)
      V = [V0 sep V1 sep V2 sep V3 sep V4 sep V5];
   elseif (nargin == 7)
      V = [V0 sep V1 sep V2 sep V3 sep V4 sep V5 sep V6];
   elseif (nargin == 8)
      V = [V0 sep V1 sep V2 sep V3 sep V4 sep V5 sep V6 sep V7];
   elseif (nargin == 9)
      V = [V0 sep V1 sep V2 sep V3 sep V4 sep V5 sep V6 sep V7 sep V8];
   elseif (nargin == 10)
      V = [V0 sep V1 sep V2 sep V3 sep V4 sep V5 sep V6 sep V7 sep V8 sep V9];
   elseif (nargin > 10) 
      error('too many arguments!'); 
   end
   
% eof