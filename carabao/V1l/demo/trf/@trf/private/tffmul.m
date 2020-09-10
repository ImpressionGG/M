function G = tffmul(G1,G2,G3,G4,G5,G6,G7,G8,G9)
%
% TFFMUL  Multiplication of two or more transfer functions:
%
%		     G = tffmul(G1,G2)
%		     G = tffmul(G1,G2,G3,...)
%
%	  Calculates the product of transfer functions G1 and G2. Up to
%         nine transfer functions may be multiplied. Operands may also 
%         be scalar: G = tffmul(5,G1).
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
   G1 = tffnew(G1);                % construct from scalar and correct sign
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


         % calculate: G = G * G2

      [ans,l] = size(G2); 
      num2 = G2(1,2:l);  den2 = G2(2,2:l);

      num1 = conv(num1,num2);
      den1 = conv(den1,den2);

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