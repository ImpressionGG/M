function oo = boost(o,r,L,Rmax)
%
% BOOST   Calculate boost rate of a mesh band utilizing 3 advertising
%         channels, with respect to repeat rate r and packet length L,
%         which is the transmission packet rate which achieves optimal
%         throughput. 
%
%            R = boost(o,r,L,Rmax)        % calculate boost rate
%            R = boost(o)              % r=3, L=0.256e-3 (256us)
%
%         Copyright(c): Bluenetics GmbH
%
%         See also: MESH, COLLSIM, OPTIMAL, YIELD
%
   if (nargin < 4)
      Rmax = 10000;
   end
   if (nargin < 3)
      L = 0.256e-3;
   end
   if (nargin < 2)
      r = 3;
   end
   
   R = 0:0.01:Rmax;                   % packet rate
   C = collision(o,R,r,L);             % collision probability
   Y = R.*(1-C);                       % yield
   
   [Ymax,idx] = max(Y);
   B = R(idx);
   
   if (nargout > 0)
      oo = B;
   else
      subplot(o);
      plot(o,R,Y,'r');
      plot(o,B*[1 1],[0 Ymax],'K',  B,Ymax,'Ko');
      
      title(sprintf(['Max. Yield: %g #/s @ Boost rate: %g #/s, Collision: %g%% ',...
           '(repeats r: %g, packet length L: %gus)'],Ymax,B,100*C(idx),r,L*1e6));
      xlabel('packet rate [#/s]');
      ylabel('yield [#/s]');
      dark(o);
   end
end
