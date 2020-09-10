function p = sloc3(perturb)
%
% SLOC1  Simulation of 6 slocs in a regular matrix alignment
%
%           p = sloc1;               % get sloc positions and draw
%           p = sloc1(0.1);          % get perturbed sloc positions and draw
%
   if (nargin < 1)
      perturb = 0;
   end
   
   p = [];
   M = 12; N = 8;
   
   for (i=1:M)
      for (j=1:N)
         p = [p [i;j]];   
      end
   end
   
      % perturbation
      
   [m,n] = size(p);
   for (i=1:10*n)
      i = Rand(1,n);
      j = Rand(1,n);
      tmp = p(:,i);  p(:,i) = p(:,j);  p(:,j) = tmp;  % swap 
   end
   
   for (j=1:n)
      ej = 0.1*[Rand(-3,3); Rand(-3,3)];
      p(:,j) = p(:,j) + perturb*ej;
   end
   
   splot(p);
end  

function r = Rand(from,to)
%
% RAND   Get a random value between 1 and n
%
   delta = 1 + to - from;
   r = from + rem(floor(delta*rand),delta);
   if (r < from || r > to)
      error('assert');
   end
end
