function q = simu(p,D,M,noise,alfa)
%
% SIMU   Simulation
%
%           simu(p,D)                  % simulate sloc position estimation
%           simu(p,D,M)                % simulate sloc position estimation
%
%        Arguments:
%           D: distance matrix
%           M: mask matrix (M(i,j)=1: consider distance(i,j), otherwise ignore
%
   if (nargin < 1)
      p = [0 0; 4 0; 4 3]';            % sloc positions
      D = dist(p);
   end
   if (nargin < 3)
      M = ones(size(D));               % all mask entries enabled
   end
   if (isempty(M))
      M = ones(size(D));
   end
   if (nargin < 4)
      noise = 0;                       % all mask entries enabled
   end
   if (nargin < 5)
      alfa = 0.3;                      % all mask entries enabled
   end
   
      % let's go ...

   [m,n] = size(p);
   
   phi = [1:n] * 2*pi/n;    
   pc = mean(p')';                     % center point  
   q = [cos(phi); sin(phi)];           % initial position guess
      
   hdl = [];                           % init graphics handles
   for (k=1:200)
      hdl = splot(p,q,D,M,hdl);
      q = iterate(q,D,M,noise,alfa);
      q = rotate(q, [1 2], 0, 2*alfa); % rotate vector set
      q = translate(q,[],pc,2*alfa);   % translate vector set
      
      if (k == 1)
         drawnow;
         pause(2);
      end
   end
end