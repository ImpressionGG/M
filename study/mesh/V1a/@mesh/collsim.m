function oo = collsim(o,R,L)           % collision simulation              
%
% COLLSIM Calculate collision probability for a packet frequency f
%         with respect to packet length Tp
%
%            C = collsim(o,R,L)        % collision propability 
%            C = collsim(o,R)          % L = 0.000256 (256us) 
%
%            collsim(o)                % draw plot
%
%         Copyright(c): Bluenetics 2021
%
%         See also: MESH, COLLISION, OPTIMAL
%
   if (nargin < 3)
      L = 0.000256;
   end
   if (nargin < 2)
      R = 0:100:4000;
   end
   
   Lms = L*1000;
   T = 1000;                           % 1000 ms observation interval
   M = 1000;                           % a big factor to use statistical
   C = 0*R;                            % init dimension
   
   Plot(o,1111);
   for (i=1:length(R))
      N = R(i)*M;
      if (N == 0)
         C(i) = 0;
         continue
      end
      
      t = rand(1,N) * (M*T-Lms);
      t = sort(t);
      
         % acollision happens if any two timestamps are closer to each
         % other than Tp
 
      dt = diff(t);

      dt1 = [dt 2*Lms];
      dt2 = [2*Lms dt];
      gdx = find(dt1>Lms & dt2>Lms);     % green - no collision

      C(i) = 1 - length(gdx) / length(dt1);

      if (nargout == 0)
         hdl = plot(R(i),100*C(i),'ro');
         hold on;
         idle(o);
      end
   end
   
   if (nargout == 0)
      hdl = plot(R,100*C,'ro');
      %set(hdl,'linewidth',3);
      subplot(o);
   else
      oo = C;
   end
   
   function Plot(o,sub)
      o = subplot(o,sub);
      plot(o,[0 max(R)],[0 100],'.');
      
      R0 = 2000*0.25/Lms;
      t0 = 0:100:R0;
      t1 = 0:50:R(end);
   
      P = t0/2000 * Lms/0.256;
      P1 = 100*(1 - exp(-t1/R0));
      plot(t0,100*P,'g', t1,P1,'c');
      
      title(sprintf('Collision Propability (packet: %g us)',Lms*1000));
      xlabel('Packet Rate [pkt/s]');
      ylabel('Collision Probability [%]');
      
      hdl = text(2000,40,'C_0 = 1 - exp(-2*R*L) =~ 2*R*L');
      set(hdl,'color',o.iif(dark(o),'w','k'),'fontsize',20);
      subplot(o);
   end
end
