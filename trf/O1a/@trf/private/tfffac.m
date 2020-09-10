function G = tfffac(V,num,den)
%
% TFFFAC   Construct transfer function based on factorized parameters,
%          means gain, linear factors (omegas) and quadratic factors
%          (omegas and zetas)
%
%          Example 1:
%
%             Gs = trf(V,{2,[5,0.7]},{0,0,[3,0.2]})
%                     
%                             (1 + s/2) * [1 + 2*0.7*s/5 + s^2/5^2
%             => G(s) = V * ----------------------------------------
%                                s^2 * [1 + 2*0.2*s/3 + s^2/3^2]
%
%          Example 2:
%                                                 1
%             Gs = trf(1,{},{2})  =>  G(s) = -----------
%                                              1 + s/2
%
%                                                   1 + s/5
%             Gs = trf(3,{5},{0})  =>  G(s) = 3 * -----------
%                                                      s
%
%          See Also: TFFNEW, TFFLF, TFFQF, TFFMUL, TFFDIV, TFFADD, TFFCMP
%
   if ~isa(V,'double')
      error('arg1 (gain) must be a double!');
   end
   if ~iscell(num)
      error('arg2 (numerator) must be a list!');
   end
   if ~iscell(den)
      error('arg3 (denominator) must be a list!');
   end
   
   G = tffnew(V,1);
   for (i=1:length(num))
      fac = num{i};
      if isa(fac,'double') && length(fac) == 1
         F = tfflf(fac);
         G = tffmul(G,F);
      elseif isa(fac,'double') && length(fac) == 2
         F = tffqf(fac(2),fac(1));
         G = tffmul(G,F);
      else
         error('all factors of numerator (arg2) must be scalar or 1x2 vector!');
      end
   end
   for (i=1:length(den))
      fac = den{i};
      if isa(fac,'double') && length(fac) == 1
         F = tfflf(fac);
         G = tffdiv(G,F);
      elseif isa(fac,'double') && length(fac) == 2
         F = tffqf(fac(2),fac(1));
         G = tffdiv(G,F);
      else
         error('all factors of numerator (arg2) must be scalar or 1x2 vector!');
      end
   end
end