classdef imat                          % IMAT Class Definition
%
% IMAT   Smart INT32 matrix representation
%
%
%        Any float number is mapped into IMAT representation by the 
%        following representation function r(x):
%
%            [m,e] = f(x)
%
%                with:  e = ceil(log2(x))    % exponent (INT8)
%                       m = 2^(bits-e)       % mantissa
%
%        where bits is the number of bit length of the integer represen-
%        tation of the mantissa (e.g: bits=32-1 for INT32, bits=64-1 for
%        INT64)
%
%        The reverse conversion function g(m,e) is given by:
%
%           x = g(m,e) = m*2^(e-bits)
%
%        In practice the representation function f(x) is implemented by 
%        the constructor imat(), while the reverse conversion function
%        g(m,e) is implemented by the cast() method of the IMAT class.
%        
%        Construction of IMAT objects:
%
%           a = imat(2,2,[1 2;4 5]);        % typical
%           a = imat(2,2,[1 2;4 5],'a');    % & provide name
%           a = imat([1 2;4 5]);            % short hand
%
%        Reverse conversion:
%
%           A = cast(a)
%
%        See also: IMAT, CAST
%
   properties
      bits                             % bit number of int representation
                                       % e.g. bits=31 for INT32 represent.
      m                                % row number
      n                                % column number
      expo                             % base 2 exponent
      mant                             % mantissa (concatenated columns)
         
      len                              % length = m*n (short hand)
      name                             % for debugging
   end
   methods                             % public methods
      function o = imat(m,n,data,name) % IMAT constructor
         o.bits = 30;                  % for INT64 representation
         assert(o.bits==30||o.bits==62);
         
         if (nargin == 1)
            data = m;
            [m,n] = size(data);
         end
         if (nargin < 4)
            name = '';
         end
         
            % establish data integrity with check
            
         if ~all(size(data) == [m,n])
            error('size mismatch!');
         end
         
         len = m*n;                    % mantissa (vector) length
         
         if (len ~= m*n || len > 6)    % size check
            error('bad sizes!');
         end
         
            % calculate greatest absolute matrix element
            
         M = max(abs(data(:)));        % greatest abs matrix element
         if (M == 0)
            M = 1;                     % fix for null matrix
         end
         
            % init data properties
            
         o.m = m;
         o.n = n;
         o.expo = ceil(log2(M));
         
         if (o.bits == 30)
            o.mant = int32(data(:)'*2^(o.bits-o.expo));  % make INT32 row
         elseif (o.bits == 62)
            o.mant = int64(data(:)'*2^(o.bits-o.expo));  % make INT64 row
         else
            error('bits value must be 30 (INT32) or 62 (INT64)');
         end
         
         o.len = len;
         o.name = name;
         
         o = itrim(o);
      end
   end
end
