function n = tffnum(G)
%
% TFFNUM  Get the numerator polynomial of a transfer function
%
%	     n = tffnum(G)
%
%         See also: TFFNEW, TFFDEN
%
   n = G(1,2:max(size(G)));

   while (n(1) == 0 & length(n) > 1 )
      n(1) = [];
   end

% eof
