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
         oo = system(o,A,B,C,D,T);
         
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
         oo = trf(o,num,den,T);
      
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
         oo = zpk(o,z,p,k,T);

      otherwise
         error('type not supported for VPA conversion');
   end
end
