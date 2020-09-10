function sloc6
%
% SLOC6  Simulation of 9 slocs aranged in a isometric raster 
%        in a noisy environment
%
   p = [[0;0] [4;0] [8;0]  [0;3] [4;3] [8;3] [0;6] [4;6] [8;6]];
   
   D = dist(p);
   M = [
         0 1 0   1 1 0   0 0 0 
         1 0 1   1 1 1   0 0 0 
         0 1 0   0 1 1   0 0 0 

         1 1 0   0 1 0   1 1 0 
         1 1 1   1 0 1   1 1 1 
         0 1 1   0 1 0   0 1 1 

         0 0 0   1 1 0   0 1 0 
         0 0 0   1 1 1   1 0 1 
         0 0 0   0 1 1   0 0 0 
       ];
   
   
   fprintf('Exact distances\n');
   disp(D);
   
      % perturbation of distances
      
   noise = 0.5;                        % 3*sigma value
   N = 1 + noise/3 * randn(size(D));
   N = abs((N+N')/2);                  % absolute symmetrized noise matrix
   
   fprintf('Perturbed distances\n');
   disp(D.*N);

      % simulation
      
   q = simu(p,D.*N,M);
end  