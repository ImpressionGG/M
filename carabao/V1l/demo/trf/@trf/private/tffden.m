function d = tffden(G)
%
% TFFDEN  Get the denominator polynomial of a transfer function
%
%	     d = den(G)
%
%         See also: TFFNEW, TFFNUM
%
   d = G(2,2:max(size(G)));

   while (d(1) == 0 & length(d) > 1 )
      d(1) = [];
   end

% eof
