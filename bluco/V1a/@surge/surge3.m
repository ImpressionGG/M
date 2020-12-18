function [out1,out2,out3] = surge3(o,x,t)
%
% SURGE3  Surge DGL für Last
%
%        Nonliear system  description: dx/dt = f(x,t)
%
%            o = tvsdiode(surge,'1');    % select TVS diode
%
%            [x0,y0] = surge3(o,[])      % initial state
%            [f,y] = surge3(o,x,t)       % dx/dt = f(x,t), y = g(x,t)
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
      
      R = Rp + Rk + R2;                % short hand
      
         % Newton's algorithm to solve for ip
         %
         %    f(ip) = ip - 1/R * [R2*il - uk - ud(ip)] = 0
         %
         %    ip´ = ip - f(ip)/f'(ip)
         %
         %    f'(ip) = 1 - 1/R * ud'(ip)

      Ipp = o.par.tvs.Ipp;
      ip1 = 0;
      ip2 = 100*Ipp;
      
      for (k=1:3)
         ip = ip1:(ip2-ip1)/100:ip2;

         ud = tvsdiode(o,{ip});
         f = ip - 1/R * [R2*il - uk - ud];

         if (f(1) == 0)
            ip = ip(1);
            break;
         else
            idxm = find(f < 0);
            idxp = find(f > 0);
            if (isempty(idxm) || isempty(idxp))
                if isempty(idxm)
                   ip = ip(idxp(1));
                else
                   ip = ip(idxm(end));
                end
               'break';
            end
            i1 = idxm(end);
            i2 = idxp(1);
            ip1 = ip(i1);  ip2 = ip(i2);
            f1 = f(i1);  f2 = f(i2);
            K = (ip2-ip1)/(f2-f1);
            ip = ip1 - K*f1;
         end
      end
      
            % final calculation of internal quantities
         
      ud = tvsdiode(o,{ip});
      ur = ip*Rp;
      up = ur + ud;
      
         % derivative
         
      f = [
             -1/(R1*Cc)*uc - 1/Cc*il;
             1/Lr*(Ug+uc) - (Rm+R2)/Lr*il + R2/Lr*ip;
             1/Ck*ip;
             ur*ip;                    % power @ Rp
             ud*ip;                    % power @ Dp
          ];
          
      g = [ip;up;ur;ud;wr;wd];
      
      out1 = f;                        % copy to output arg
      out2 = g;                        % copy to output arg
   elseif (nargin == 2)
      x0 = [U0; 0; 0; 0; 0];
      out1 = x0;                       % copy to outarg
      out2 = [0;0;0;0;0;0];            % copy to outarg
   end
end
