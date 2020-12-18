function [out1,out2,out3] = surge4(o,x,t)
%
% SURGE4  Surge DGL für Last mit X2 Kondensator
%
%        Nonliear system  description: dx/dt = f(x,t)
%
%            o = tvsdiode(surge,'1');    % select TVS diode
%
%            [x0,y0] = surge4(o,[])      % initial state
%            [f,y] = surge4(o,x,t)       % dx/dt = f(x,t), y = g(x,t)
%
%        See also: SURGE, HEUN, SURGE1, SURGE2, SURGE3
%
   p = o.par.parameter;      % access to parameters
   
   Cc = p.Cc;                % [F]
   Cp = p.Cp;                % [F]
   R1 = p.R1;                % [Ohm]
   R2 = p.R2;                % [Ohm]
   Rm = p.Rm;                % [Ohm]
   Lr = p.Lr;                % [H]
   U0 = p.U0;                % [V]
   Ug = p.Ug;                % [V]
   
   Rp = p.Rp;
   Rk = p.Rk;
   Ck = p.Ck;
   
   if (nargin == 3)     
      uc = x(1);
      il = x(2);
      uk = x(3);
      wr = x(4);                       % energy @ resistor
      wd = x(5);                       % energy @ diode
      ud = x(6);                       % voltage @ X2 capacitor
      
      R = Rp + Rk + R2;                % short hand         
      id = tvsdiode(o,ud);
      ik = (R2*il-uk-ud)/R;
      ur = ik*Rp;
      up = ur + ud;
      
      ic = ik-id;                      % Kondensator Strom 
      
         % derivative
         
      f = [
             -1/(R1*Cc)*uc - 1/Cc*il;
             1/Lr*(Ug+uc) - (Rm+R2)/Lr*il + R2/Lr*ik;
             1/Ck*ik;
             ur*ik;                    % power @ Rp
             ud*id;                    % power @ Dp
             1/Cp*(ik-id);
          ];
          
      g = [id;up;ur;ud;wr;wd;ic];
      
      out1 = f;                        % copy to output arg
      out2 = g;                        % copy to output arg
   elseif (nargin == 2)
      x0 = [U0; 0; 0; 0; 0; Ug];
      out1 = x0;                       % copy to outarg
      out2 = [0;0;0;0;0;0;0];            % copy to outarg
   end
end
