function [p,Tt,Ttim] = steady(mode,A,B,C,D,Tgiven,Tp,T0)
%
% STEADY   Calculate steady power to given steady state
%
%             [p,Tt] = steady('Ttim',A,B,C,D,Ttim,Tp,T0)
%
%             [p,Ttim] = steady('Tt',A,B,C,D,Tt,Tp,T0)
%
   switch (mode)
      case 'Ttim'    % given Ttim
         Ttim = Tgiven;
         xl = Ttim - T0;
   
            % now calculate steady state   

         F = eye(size(A)) - A; 
         Finv = inv([F(:,1) -B(:,1)]); 
         v = Finv * (B(:,2:3)*[Tp;T0] - F(:,2)*xl);
   
         Tt = v(1) + T0;   % steady tool temperature
         p = v(2);         % steady power

         if (abs(p) > 1e8)
            [p,Tt,Ttim] = steady('Tt',A,B,C,D,Tgiven,Tp,T0);
         end
       case 'Tt'    % given Tt (thermode temperature)
         Tt = Tgiven;
         xT = Tt - T0;
   
            % now calculate steady state   

         F = eye(size(A)) - A; 
         v = inv([F(:,2) -B(:,1)]) * (B(:,2:3)*[Tp;T0] - F(:,1)*xT);
   
         Ttim = v(1) + T0;   % steady TIM temperature
         p = v(2);           % steady power
         
      otherwise
         error('bad mode!');  
end

