function b = iinv(a,name)
%
% IINV  calculate inverse IMAT
%
%           b = iinv(a)         
%           b = iinv(a,'InvA')       % b = inv(a), provide result name
%
%        See also IMAT, ICAST, IMUL, ISUB, ITRN
%
   if (nargin < 2)
      name = '';
   end
   if (a.m ~= a.n)
      error('no quadratic matrix!');
   end
   
   b = a;
   b.name = name;
   base = 2^b.expo;
   
      % down sizing of mantissa while upsizing of exponent
      % mantissa of b is down sized by an extra factor of 2 in order
      % to have room for overflow during "addition of products"
   
   expx = ceil(b.bits/2);              % need extra bits
   expa = a.expo + expx;               % upsize exponent of A
      
      % depending on matrix dimension
      
   if (a.m == 1)
      
      one.expo = -1;                      % exponent of '1'
      one.mant = 2^31;                    % mantissa of '1'
      
      expx = ceil(b.bits/2);     
      expa = a.expo + expx;               % upsize exponent of A

      mant = a.mant / 2^expx;
      
      b.mant = one.mant / mant;
      b.expo = one.expo - expa + b.bits;
      
   elseif (a.m == 2)

      a11 = a.mant(1) / 2^expx;        % downsize a11
      a21 = a.mant(2) / 2^expx;        % downsize a21
      a12 = a.mant(3) / 2^expx;        % downsize a12
      a22 = a.mant(4) / 2^expx;        % downsize a22

         % calc determinant and check if zero
         
      det = imat(1);
      det.mant = a11*a22 - a12*a21;        
      det.expo = a.expo + a.expo + 2*expx - det.bits;

      if (det.mant == 0)
         error('singular matrix!');
      end
      
         % trim determinant and calculate inverse
         
      det = itrim(det);
      idet = iinv(det); 
      
         % downscale idet and calculate resul matrix elements
         
      mant = idet.mant / 2^expx;

      b.mant(1) = a22*mant;            % b(1,1)
      b.mant(2) = -a21*mant;           % b(2,1)
      b.mant(3) = -a12*mant;           % b(1,2)
      b.mant(4) = a11*mant;            % b(2,2)
      
      b.expo = a.expo + idet.expo + 2*expx - b.bits;
      
   else
      error('matrix dimension must be 1 or 2!');
   end
   
   b = itrim(b);
end
