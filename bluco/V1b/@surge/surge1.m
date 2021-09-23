function [out1,out2,out3] = surge1(o,x,t)
%
% SURGE1  Surge DGL im Leerlauf
%
%        Nonliear system  description: dx/dt = f(x,t)
%
%            [x0,y0] = surge1(o,[])      % initial state
%            [f,y] = surge1(o,x,t)       % dx/dt = f(x,t), y = g(x,t)
%
%        See also: SURGE, HEUN, SURGE1, SURGE2
%
   p = o.par.parameter;      % access to parameters

   Cc = p.Cc;                % [F]
   R1 = p.R1;                % [Ohm]
   R2 = p.R2;                % [Ohm]
   Rm = p.Rm;                % [Ohm]
   Lr = p.Lr;                % [H]
   U0 = p.U0;                % [V]
   
   if (nargin == 3)     
      uc = x(1);
      il = x(2);
      
      f = [
             -1/(R1*Cc)*uc - 1/Cc*il;
             1/Lr*uc - (Rm+R2)/Lr*il;
          ];
          
      g = il*R2;
      
      out1 = f;   % copy to output arg
      out2 = g;   % copy to output arg
   elseif (nargin == 2)
      x0 = [U0; 0];
      out1 = x0;    % copy to outarg
      out2 = 0;     % copy to outareg
   end
end
