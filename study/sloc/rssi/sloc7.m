function sloc7
%
% SLOC7  Simulation of 6 slocs aranged in a isometric raster 
%        in a noisy environment
%
   p = [[0;0] [4;0] [8;0]  [0;3] [4;3] [8;3]];
   
   D = dist(p);
   M = [
         0 1 1   1 1 0
         1 0 1   1 1 1 
         1 1 0   0 1 1 

         1 1 0   0 1 1 
         1 1 1   1 0 1 
         0 1 1   1 1 0 
       ];
   
   fprintf('Exact distances\n');
   disp(D);
   
      % perturbation of distances
      
   noise = 0.1;                        % 3*sigma value
   N = 1 + noise/3 * randn(size(D));
   N = abs((N+N')/2);                  % absolute symmetrized noise matrix
   
   fprintf('Perturbed distances\n');
   disp(D.*N);

      % simulation
      
   q = simu(p,D.*N,M);
end  