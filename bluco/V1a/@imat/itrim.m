function o = itrim(o)
%
% ICAST  Trim IMAT in order to have best mantissa representation
%
%           a = itrim(a)
%
%        See also IMAT, ITRN, IMUL, ISUB, IINV, ITRIM
%
   M = max(abs(o.mant(:)));            % max abs element of mantissa
   
   if (M > 0)
      if (M >= 2^o.bits)               % (M >= 2^30) or (M >= 2^62)
         o.mant = o.mant / 2^1;
         o.expo = o.expo + 1;
      elseif (M < 2^(o.bits-1))        % (M >= 2^29) or (M >= 2^61)
         shift = 0;
         while (M < 2^(o.bits-4))      % (M >= 2^26) or (M >= 2^58)
            M = M * 2^4;
            shift = shift + 4;
         end

         while (M < 2^(o.bits-2))      % (M >= 2^28) or (M >= 2^60)
            M = M * 2^2;
            shift = shift + 2;
         end

         while (M < 2^(o.bits-1))      % (M >= 2^29) or (M >= 2^61)
            M = M * 2^1;
            shift = shift + 1;
         end

         if (o.bits == 30)
            o.mant = int32(o.mant * 2^shift);
         elseif (o.bits == 62)
            o.mant = int64(o.mant * 2^shift);
         else
            error('bits must have value 30 (INT32) or 62 (INT64)!');
         end
         o.expo = o.expo - shift;
      end
   end
   
       %  we finish with a final assertion which confirms data integritys
      
   M = max(abs(o.mant(:)));            % max abs element of mantissa
   if (o.bits == 30)
      assert(M == 0 || (M >= 2^29 && M < 2^30));
   else
      assert(M == 0 || (M >= 2^61 && M < 2^62));
   end
end