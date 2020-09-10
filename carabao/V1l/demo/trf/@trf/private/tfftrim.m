function F = tfftrim(G)
%
% TFFTRIM  Trim transfer function
%
%             F = tfftrim(G)
%
%          Trim tranfer function in order to get a normalized repre-
%          sentation:
%
%             a) Convert scalar number to transfer function
%             b) Do sign correction
%             c) Remove leading zeros
%             d) Normalize to have a 1 for the highest order denominator
%                coefficient (if the numerator degree is higher than the
%                denominator degree then the numerator will be normalized)
%
%          Example:
%
%             ad a)  G = 2                               F = tfftrim(G)
%             ad b)  G = -tffnew([1],[1 2 3]);           F = tfftrim(G)
%             ad c)  G = tffnew([0 0 0 1],[0 0 1 2 3]);  F = tfftrim(G)
%             ad d)  G = tffnew([2 1],[4 2 3]);          F = tfftrim(G)
%
%          See also: tffnew, tffcan
%

   [class,kind,sign] = ddmagic(G);

   if ( class == 0 )
      F = tffnew(G,1);
      return
   end
   if ( class ~= tffclass )
      G = tff(G);		% try to coerce
      % error('argument 1 must be scalar or transfer function');
   end

      % extract numerator and denominator

   if ( sign < 0 )
      G(1) = -G(1);  G(2,:) = -G(2,:);
   end

      % remove leading zeros

   while( all(G(:,2) == 0) )
      G(:,2) = [];
   end 

      % normalize to let highest order coefficient be 1

   [ans,l] = size(G);

   if ( G(2,2) ~= 0 )
      G(:,2:l) = G(:,2:l) / G(2,2);   % normalize denominator
   else
      G(:,2:l) = G(:,2:l) / G(1,2);   % normalize numerator
   end

   F = G;

% eof   
