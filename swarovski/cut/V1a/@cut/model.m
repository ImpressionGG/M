function [A1,A2,b] = model(o,x,t)
%   
% MODEL  Hoffmann/Gaul system model, version 2
%
%        1) Nonliear system  description: dx/dt = f(x,t)
%
%            x0 = model(o,[])       % initial state
%            f = model(o,x,t)       % dx/dt = f(x,t)
%
%        2) Linear system description: dx/dt = A1*x+b, dx/dt = A2*x+b 
%
%            [A1,A2,b] = model(o)   % linear systems: dx/dt = Ai*x+b
%
   f = get(o,"model");
   
   if (nargin == 3)
      A1 = f(o,x,t);                   % state derivative
   elseif (nargin == 2)
      A1 = f(o,[]);                    % initial state
   elseif (nargin == 1)
      [A1,A2,B] = f(o);                % linearized systems
   elseif (nargin == 0)
      f(o);                            % display system matrices
   end
