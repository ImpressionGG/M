function G = tffadd(G1,G2,G3,G4,G5,G6,G7,G8,G9)
%
% TFFADD  Addition of two or more transfer functions:
%
%		     G = tffadd(G1,G2)
%		     G = tffadd(G1,G2,G3,...)
%
%	  Calculates the sum of transfer functions G1 and G2. Up to nine
%         transfer functions may be added. Operands may also be scalar:
%         G = tffadd(5,G1).
%
%	  It is also possible to subtract transfer functions. Simply type
%         G = tffadd(G1,-G2,-G3).
%
%         The kinds and sampling periods of the input argument transfer
%         functions may differ. The first (non scalar) transfer function
%         of the input argument list determines the resulting kind.
%     
%         No automatic cancellation or trimming is done (see tffcan or
%         tfftrim).
%
%         See Also: tffnew, tffcan, tfftrim, tffadd, tffsub, tffmul, tffdiv
%

   Nargin = nargin;       % copy - modify later

   [class,kind] = ddmagic(G1);
   G1 = tfftrim(G1);
   Ts = G1(2);

   [ans,l] = size(G1); 
   num1 = G1(1,2:l);  den1 = G1(2,2:l);


      % with rest of argument list do operation


   while ( Nargin >= 2 )

      if ( kind == 0)
         [class,kind] = ddmagic(G2);
         G2 = tffnew(G2);            % construct from scalar and correct sign
         Ts = G2(2);
      else
         G2 = tffnew(G2);            % construct from scalar and correct sign
      end

      G2 = tfftrim(G2);

         % calculate: G = G + G2

      [ans,l] = size(G2); 
      num2 = G2(1,2:l);  den2 = G2(2,2:l);

      equal = (length(den1) == length(den2));
      if ( equal ) equal = all(den1 == den2); end      

      if ( equal )
         n1 = num1;  n2 = num2;
         s1 = max(size(n1));   s2 = max(size(n2));  s = max(s1,s2);
         n1 = [zeros(1,s-s1), n1];  n2 = [ zeros(1,s-s2), n2];
         num1 = n1 + n2;
      else
         n1 = conv(num1,den2); n2 = conv(num2,den1);
         s1 = max(size(n1));   s2 = max(size(n2));  s = max(s1,s2);
         n1 = [zeros(1,s-s1), n1];  n2 = [ zeros(1,s-s2), n2];
         num1 = n1 + n2;
         den1 = conv(den1,den2);
      end

         % shift arguments

      for (i = 2:Nargin-1)
         eval(['G','0'+i,'=G','0'+i+1,';']);
      end
      Nargin = Nargin-1;
   end

      % construct resulting transfer function

   if ( kind == 0 ) kind = 1; end
   G = tffnew(num1,den1);  G(1) = ddmagic(tffclass,kind);  G(2) = Ts;

% eof
