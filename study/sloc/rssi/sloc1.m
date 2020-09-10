function sloc1(noise,alfa)
%
% SLOC1  Simulation of 3 slocs in an orthogonal 3/4/5 m triangle
%
   if (nargin < 1)
      noise = 0;
   end
   if (nargin < 2)
      alfa = 0.05;
   end
   
   p = [[0;0] [4;0]  [4;3]];
   D = dist(p);
   
   q = simu(p,D,[],noise,alfa);
end  