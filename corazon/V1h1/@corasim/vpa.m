function oo = vpa(o,digits)
%
% VPA     Convert transfer system to VPA based representation. Let o be
%         a CORASIM object of type 'css','dss','strf','ztrf','qtrf','szpk',
%         then
%
%            o = system(corasim,A,B,C,D,T)
%
%            oo = vpa(o)               % VPA conversion with digits default
%            oo = vpa(o,64)            % 64 VPA digits
%            oo = vpa(o,0)             % convert to double representation
%
%
%         Copyright(c): Bluenetics 2021
%
%         See also: CORASIM, SYSTEM, TRF, ZPK, TRFVAL
%
   if (nargin < 2)
      digits = nan;
   end
   
   switch o.type
      case {'css','dss'}
         [A,B,C,D,T] = system(o);
         if isnan(digits)              % use digit default
            A = vpa(A);  B = vpa(B);  
            C = vpa(C);  D = vpa(D);
            T = vpa(T);
         elseif (digits == 0)          % convert to double
            A = double(A);  B = double(B);  
            C = double(C);  D = double(D);
            T = double(T);
         else                          % VPA with specified digits 
            A = vpa(A,digits);
            B = vpa(B,digits);  
            C = vpa(C,digits);
            D = vpa(D,digits);
            T = vpa(T,digits);
         end
         oo = o;
         oo.data.A = A;
         oo.data.B = B;
         oo.data.C = C;
         oo.data.D = D;
         oo.data.T = T;
         
      case {'strf','ztrf','qtrf'}
         [num,den,T] = trf(o);
         if isnan(digits)              % use digit default
            num = vpa(z);  
            den = vpa(p);  
            T = vpa(T);
         elseif (digits == 0)          % convert to double
            num = double(num);  
            den = double(den);  
            T = double(T);
         else                          % VPA with specified digits 
            num = vpa(num,digits);  
            den = vpa(den,digits);  
            T = vpa(T,digits);
         end
         oo = o;
         oo.data.num = num;
         oo.data.den = den;
         oo.data.K = k;
       
      case {'szpk','zzpk','qzpk'}
         [z,p,k,T] = zpk(o);
         if isnan(digits)              % use digit default
            z = vpa(z);  p = vpa(p);  
            k = vpa(k);  T = vpa(T);
         elseif (digits == 0)          % convert to double
            z = double(z);  p = double(p);  
            k = double(k);  T = double(T);
         else                          % VPA with specified digits 
            z = vpa(z,digits);  p = vpa(p,digits);  
            k = vpa(k,digits);  T = vpa(T,digits);
         end
         
            % zeros and poles in VPA representation might have a
            % representation in double as infinity, and have to be
            % eliminated
            
         idx = find(isinf(p));
         if ~isempty(idx)
            p(idx) = [];
         end
         
         idx = find(isinf(z));
         if ~isempty(idx)
            z(idx) = [];
         end
         
         oo = o;
         oo.data.zeros = z;
         oo.data.poles = p;
         oo.data.K = k;
         oo.data.T = T;

      case 'matrix'
         [m,n] = size(o);
         for (i=1:m)
            for (j=1:n)
               Gij = peek(o,i,j);
               Gij = vpa(Gij,digits);
               o = poke(o,Gij,i,j);
            end
            oo = o;
         end
         
      otherwise
         error('type not supported for VPA conversion');
   end
end
