function sloc5
%
% SLOC5  Simulation of 5 slocs aranged in a rectangle 
%        in a noisy environment
%
   p = [[0;0] [4;0]  [4;3] [0;3]];
   
   D = dist(p);
   fprintf('Exact distances\n');
   disp(D);
   
      % perturbation of distances
      
   noise = 0.8;                        % 3*sigma value
   N = 1 + noise/3 * randn(size(D));
   N = abs((N+N')/2);                  % absolute symmetrized noise matrix
   
   fprintf('Perturbed distances\n');
   disp(round(D.*N*10)/10);

      % simulation
      
   q = simu(p,D.*N);
end  