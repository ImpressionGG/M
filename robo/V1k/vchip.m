function [V,VX1,VX2,VY1,VY2] = vchip(n,m,text)
%
% VCHIP     Vector Set to plot a chip with m x n pads.
%
%              V = vchip(n,m)
%              V = vchip        % m = 3, n = 3, text = 'DATACON', size 1 x 1
%              V = vchip(n,m,'DATACON')
%
%           See also: ROBO, VPLT, VCAT, VTEXT, VCHIP
%
   if (nargin < 3) text = ''; end
   if (nargin == 0) n = 3; m = 3; text = 'DATACON'; end

   wp = 4;   % width of pad
   hp = 4;   % height of pad
   dp = 1;   % distance of pads
   
   width  = (n+2)*(wp+dp);
   height = (m+2)*(hp+dp);
   
   Vpad = vrect(wp,hp);
   Vcross = [wp/2 0; wp/2 hp; NaN NaN; 0 hp/2; wp hp/2]';
   Vcross = vcat(Vcross,vmove(vrect(wp/2,hp/2),wp/4,hp/4));
   
   V = Vpad;
   x = 0; y = 0;
   for(i=1:n-1)
      x = x + wp + dp;
      V = vcat(V,vmove(Vpad,x,y));
   end
   VX1 = vmove(V,1.5*dp+wp,dp/2); 
   VX2 = vmove(V,1.5*dp+wp,height-dp/2-hp); 
   
   V = Vpad;
   x = 0; y = 0;
   for(i=1:m-1)
      y = y + hp + dp;
      V = vcat(V,vmove(Vpad,x,y));
   end
   VY1 = vmove(V,dp/2,1.5*dp+hp); 
   VY2 = vmove(V,width-dp/2-wp,1.5*dp+hp); 
   
   V = vrect(width,height);
   V = vcat(V,VX1,VY1,VX2,VY2);
   
   Vcrosses = vcat(vmove(Vcross,dp/2,0),vmove(Vcross,width-dp/2-wp,0));
   Vcrosses = vcat(vmove(Vcrosses,0,dp/2),vmove(Vcrosses,0,height-hp-dp/2));
   V = vcat(V,Vcrosses);
   
   if length(text) > 0        % provide also text
      Vtxt = vtext(text);
      wt =  max(Vtxt(1,:));
      ht =  max(Vtxt(2,:));
      
      % Vtxt = Vtxt * n*wp/wt;  % scale text
      
      Vtxt(1,:) = Vtxt(1,:) * n*wp/wt;  % rescale text
      Vtxt(2,:) = Vtxt(2,:) * m*hp/ht;  % rescale text
      
      wt =  max(Vtxt(1,:));
      ht =  max(Vtxt(2,:));
      
      V = vcat(V,vmove(Vtxt,(width-wt)/2,(height-ht)/2));
   end
   
% final scaling
   
   V = V/25;
% eof