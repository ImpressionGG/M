function oo = yield(o,R,r,L)
%
% YIELD   Calculate yield for a particular packet rate regarding a mesh 
%         band utilizing 3 advertising channels, with respect to repeat
%         rate r and packet length L. Yield relates to successful packet
%         rate after transmitting an intended packet rate R.
%
%            R = yield(o,R,r,L)        % calculate yield
%            R = yield(o,R)            % r=3, L=0.256e-3 (256us)
%
%         Formula:
%
%            lambda := 2/3*R*L
%            C = [1-exp(-lambda*r)]^r
%            Y = R*(1-C) 
%                
%
%         Copyright(c): Bluenetics 2021
%
%         See also: MESH, COLLSIM, OPTIMAL, YIELD
%
   if (nargin < 4)
      L = 0.256e-3;
   end
   if (nargin < 3)
      r = 3;
   end
   
   C = collision(o,R,r,L);             % collision probability
   Y = R.*(1-C);                       % yield

   oo = Y;
end
