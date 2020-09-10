function p = sloc1(perturb)
%
% SLOC1  Simulation of 6 slocs in a regular matrix alignment
%
%           p = sloc1;               % get sloc positions and draw
%           p = sloc1(0.1);          % get perturbed sloc positions and draw
%
   if (nargin < 1)
      perturb = 0;
   end
   
   p = [[1;0] [1;2] [0;0] [1;1] [0;1] [0;2]];
   
   e = [[-1;2] [3;-2] [1;0] [1;-2] [2;-3] [1;2]] * perturb;   % perturbation
   
   p = p+e;
   
   splot(p);
end  