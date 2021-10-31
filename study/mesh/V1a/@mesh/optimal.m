function [oo,o1,o2,o3] = optimal(o,R,L)           % Optimal Repeat Count
%
% OPTIMAL  Calculate optimal repeat count (a fictive real number) for a 
%          network with packet length L and packet rate R
%
%             r = optimal(o,R,L)       % optimal repeat rate
%             r = optimal(o,R)         % default: L = 0.000256
%
%             r = optimal(o,[100,200,500,1000,1500])
%             [r0,C0,r,C] = optimal(o,R); 
%
%          R may be either a scalar or row/column vector. The result is a
%          matrix with the same dimensions as R.
%
%          Theory:
%             lambda = 2/3*R*L        % auxillary quantity
%             C = [1 - exp(-lambda*r)]^r
%
%          Copyright(c): Bluenetics 2021
%
%          Se also: MESH
%
   if (nargin < 3)
      L = 0.000256;                    % default packet length 256us
   end
   
   if (min(size(R)) ~= 1)
      error('R (arg2) must be a row pr column vector');
   end
   
   r = 0:0.001:15;  
   m = length(R);
   n = length(r);
   
   C = zeros(m,n);
   r0 = zeros(m,1);
   C0 = zeros(m,1);
      
   for (i=1:m)
      lambda = 2/3 * R(i)*L;
      
      C(i,:) = [1 - exp(-lambda*r)].^r;      
      [C0(i),idx] = min(C(i,:)); 
      r0(i) = r(idx);
   end
   
   if (nargout==0)
      PlotC(o,121);
      PlotO(o,2212);                   % optimal repeat number
      PlotM(o,2222);                   % minimal collision probability
   elseif (nargout == 1)
      oo = r0;
   else
      oo = r0;  o1 = C0;  o2 = r;  o3 = C;  
   end
   heading(o,'Optimal Repeat Rate and Related Collision Probability');
   
   function PlotC(o,sub)               % Collision Probability
      o = subplot(o,sub);
      cols = {'r','g','b','ryyy','m','c','kw'};
      for (i=1:m)
         hdl = plot(r,100*C(i,:));
         col = cols{1+rem(i-1,length(cols))};
         o.color(hdl,col);
         hold on;

         hdl = plot(r0(i),100*C0(i),'p');
         o.color(hdl,col);
         
         x = 0.3 + r0(i);  y = 100*C0(i);
         hdl = text(x,y,sprintf('%g',R(i)));
         set(hdl,'color',o.color(col));
         
         set(gca,'ylim',[0 25]);
      end

      xlim = [0, 3*ceil(max(r0)/3)];
      set(gca,'xlim',xlim, 'xtick',0:3:xlim(2));
      
      title(sprintf('Collision Probability (L: %g us)',L*1e6));
      xlabel('Repeats [#]');
      ylabel('Collision Probability [%]');
      subplot(o);
   end
   function PlotO(o,sub)               % Optimal Repeat Number         
      o = subplot(o,sub);
      plot(o,R,r0,'g3');
      
      ylim = [0, 3*ceil(max(r0)/3)];
      set(gca,'xlim',[300 max(R)], 'ylim',ylim);
      set(gca,'xtick',0:100:max(R));
      set(gca,'ytick',0:3:ylim(2));

      title(sprintf('Optimal Repeat Number (L: %g us)',L*1e6));
      ylabel('Repeats [#]');
      xlabel('Packet Rate [#/s]');
      subplot(o);
   end
   function PlotM(o,sub)               % Minimal Collision Probability 
      o = subplot(o,sub);
      plot(o,R,100*C0,'r3');
      set(gca,'xtick',0:100:max(R));
      set(gca,'ytick',0:2:ceil(max(100*C0)/2)*2);

      title(sprintf('Minimal Collision Probability (L: %g us)',L*1e6));
      xlabel('Packet Rate [#/s]');
      ylabel('Collision Probability [%]');
      subplot(o);
   end
end