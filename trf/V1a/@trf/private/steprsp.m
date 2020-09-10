function y = steprsp(num,den,t)
%
% STEPRSP    Calculate step response of a transfer function
%
   if (1)   % use control toolbox
      if length(num) == 1 && length(den) == 1
         y = num/den * ones(size(t));
      else
         y = step(num,den,t);
      end
      return
   end
   
   [A,B,C,D] = tf2ss(num,den);

   if (length(t) == 1)
      N = 500;                     % 500 points
      %N = 1000;
      tmax = t;
      t = 0:tmax/N:tmax;
   end
   Ts = diff(t(1:2));
   
   Phi = expm(A*Ts);
   
   H0 = 1/2*(Phi+eye(size(Phi))) * B*Ts;  % approximately
   
      % calculate: H = integral{0,Ts}(Phi(tau)*B*dtau)
   
   H = 0*B; nmax = 100;
   %nmax=200;   
   for(i=1:nmax)
      tau = Ts*i/nmax;
      Phitau = expm(A*tau);
      H = H + Phitau*B*Ts/nmax;
   end
   
   
   xk = 0*B;                    % initial state
   
   uk = 1;
   y = 0*t;
   for (k=1:length(t))
      y(k) = C*xk + D*uk;
      xk = Phi*xk + H*uk;
   end
end
