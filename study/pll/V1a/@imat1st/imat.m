classdef imat                          % IMAT Class Definition
   properties
      m                                % row number
      n                                % column number
      len                              % length = m*n
      expo                             % base 2 exponent
      data                             % data (concatenated columns)
      margin                           % representation margin
      maxi                             % max representable number
      name                             % for debugging
   end
   methods                             % public methods
      function o = imat(m,n,d,name,e)  % IMAT constructor
      %
      % IMAT  IMAT constructor
      %
      %          a = imat(2,2,[1 2;4 5]);        % typical
      %          a = imat(2,2,[1 2;4 5],'a');    % & provide name
      %          a = imat(2,2,[1 2;4 5],'a',12); % & provide exponent 12
      %     
         if (nargin == 1)
            d = m;
            [m,n] = size(d);
         end
         
         if (size(d,1)~=m || size(d,2)~=n)
            error('size mismatch!');
         end
         
         d = d(:)';                    % make a row
         
         if (length(d)~=m*n || length(d(:))>4)
            error('bad sizes!');
         end
         if (nargin < 4)
            name = '';
         end
         if (nargin < 5)
            e = 10;                    % default exponent
%e=20;            
         end
         o.m = m;
         o.n = n;
         o.len = m*n;
         o.expo = e;
         o.name = name;

         base = 2^e;
         o.data = round(d*base);
         if (o.expo <= 15)
            o.maxi = 2^31;
         else
            o.maxi = 2^63;
         end
         
         if any(abs(o.data) >= o.maxi)
            error('cannot represent data as an IMAT object!');
         end
         o.margin = o.maxi / max(abs(o.data));
      end
   end
end
