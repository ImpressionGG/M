function sloc3(noise,alfa)
%
% SLOC3  Simulation of 3 slocs aranged in an orthogonal triangle 
%        in a noisy environment
%
   if (nargin < 1)
      noise = 0;
   end
   if (nargin < 2)
      alfa = 0.05;
   end
   
   p = [[0;0] [4;0]  [4;3]];
   
   D = dist(p);
   fprintf('Exact distances\n');
   disp(D);
   
      % perturbation of distances
      
   Noise = 0.5;                        % 3*sigma value
   N = 1 + Noise/3 * randn(size(D));
   N = abs((N+N')/2);                  % absolute symmetrized noise matrix
   
   fprintf('Perturbed distances\n');
   disp(D.*N);

      % simulation
      
   q = simu(p,D.*N,[],noise,alfa);
end  