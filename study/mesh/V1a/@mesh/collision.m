function oo = collision(o,R,r,L)
%
% COLLISION   Calculate collision probability for packet rate R over the 
%             the mesh band utilizing 3 advertising channels, with respect
%             to repeat rate r and packet length L. 
%
%                C = collision(o,R,r,L)     % collision propability 
%                C = collision(o,R,r)       % L = 0.256e-3 (250us), r=3 
%
%                C = collision(o,500,6);
%                C = collision(o,1000,[2 3])% 2 application repeats, 3
%                network repeats
%
%             Formula:
%
%                lambda = 2/3 * R*L
%                C = [1-exp(-lambda*r)]^r
%                
%             For the collision probability in a single channel we have:
%
%                C0 = 1 - exp(-2*R*L)
%
%             If we have 3 advertising channels and the packets are
%             statistically dispatched to a random advertising channel,
%             then we have R/3 packet rate per channel. If the packets are
%             r-times repeated then we have R/3*r as the packet rate in a
%             single advertising channel. The probability that a single 
%             packet of the r repeated packages collides is
%
%                C' = 1 - exp(-2*(R/3*r)*L)
%
%             With r repeats the probability scales down with power of r.
%             So we get:
%
%                C = (C')^r = [1-exp(-2/3*R*L*r)]^r
%
%             Let lambda := 2/3*R*L then
%
%                C = [1-exp(-lambda*r)]^r]
%
%             Copyright(c): Bluenetics 2021
%
%             See also: MESH, COLLSIM, OPTIMAL
%
   if (nargin < 4)
      L = 0.256e-3;
   end
   if (nargin < 3)
      r = 3;
   end
   if (nargin < 2)
      R = 0:10:1000;
   end
   
   r = prod(r);
   lambda = 2/3 * R*L;
   C = [1 - exp(-lambda*r)].^r;      
   
   oo = C;
end
