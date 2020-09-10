function sloc2(noise)
%
% SLOC2  Simulation of 4 slocs aranged in a square
%
   if (nargin < 1)
      noise = 0;
   end
   
   p = [[0;0] [4;0]  [4;3] [0;3]];
   D = dist(p);
   
   q = simu(p,D,[],noise);
end  