function V = vtext(str)
%
% VTEXT     Vector Set representing text
%
%              V = vtext('Text')
%
%           See also: ROBO, VPLT, VCAT, VRECT, VCHIP
%
   V0 = [2 0; 0 1; 0 7; 2 8; 6 8; 8 7; 8 1; 6 0; 2 0; NaN NaN; 0 1; 8 7]';
   VA = [0 0; 0 6; 2 8; 6 8; 8 6; 8 0; NaN NaN; 0 3; 8 3]';
   VB = [0 0; 0 8; 6 8; 8 7; 8 5; 6 4; 8 3; 8 1; 6 0; 0 0; NaN NaN; 0 4; 6 4]';
   VC = [8 1; 6 0; 2 0; 0 1; 0 7; 2 8; 6 8; 8 7]';
   VD = [0 0; 0 8; 6 8; 8 7; 8 1; 6 0; 0 0]';
   VE = V0;
   VF = V0;
   VG = V0;
   VH = V0;
   VI = V0;
   VJ = V0;
   VK = V0;
   VL = V0;
   VM = V0;
   VN = [0 0; 0 8; 8 0; 8 8]';
   VO = [2 0; 0 1; 0 7; 2 8; 6 8; 8 7; 8 1; 6 0; 2 0]';
   VP = V0;
   VQ = V0;
   VR = V0;
   VS = V0;
   VT = [4 0; 4 8; NaN NaN; 0 8; 8 8]';
   VU = V0;
   VV = V0;
   VW = V0;
   VX = V0;
   VY = V0;
   VZ = V0;

   str = upper(str);   % convert to upper case letters
   
   x = 0;
   for i=1:length(str)
      c = str(i);
      if c < 'A' | c > 'Z'
         Vc = vcat(V,V0);
      else
         eval(['Vc = V',c,';']);
      end
      
      Vc(1,:) = Vc(1,:)+x;
      if (i==1) V = Vc; else V = vcat(V,Vc); end
      
      x = x+10;
   end
   
   V = V/10;
% eof