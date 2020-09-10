function col = pcolor(obj,psi)
%
% PCOLOR   color of a complex number or complex array
%          The phase determines the color and the magnitude the brightness
%          (0: dark, >=1: bright)
%
%            col = color(quantana,psi);
%            col = color(quantana,0.5+0.3*i);
%
   psi = psi(:);

   idx = find(isnan(psi));
   if (~isempty(idx))
      psi(idx) = 0*idx;
   end
   
   table = [[1 -1 -1]; [ 1 0 -1]; [1 1 -1]; [-1 1 0]; [0 1 -1];
            [-1 1  1]; [-1 -1 1]; [1 -1 1]; [1 -1 -1]];


   phi = rem(360+angle(psi) * 180/pi,360);
   r = abs(psi);
   r = min(r,ones(size(psi)));

   idx = 1 + floor(phi/45);
   lambda = (phi - (idx-1)*45)/45;
 
   col = zeros(length(psi),3);
   for (i=1:length(psi))
      col1 = table(idx(i),:);
      col2 = table(idx(i)+1,:);
      col(i,:) = r(i) * (1 + col1 + (col2-col1)*lambda(i))/2;
   end

   return
