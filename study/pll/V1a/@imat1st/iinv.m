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
   
   if (a.m == 1)
      b.data = base*base/a.data; 
      icheck(b,b.data,'iinv');
   elseif (a.m == 2)
      a11 = a.data(1);
      a21 = a.data(2);
      a12 = a.data(3);
      a22 = a.data(4);

         % calc summands of determinant
         
      a11a22 = a11*a22;     icheck(b,a11a22,'iinv');
      a21a12 = a21*a12;     icheck(b,a21a12,'iinv');
      
         % calc determinant and check for zero
         
      det = a11a22-a21a12;    
      if (det == 0)
         error('singular matrix!');
      end
      icheck(a,det,'iinv');
      
         % invert determinant
         
      det = det/base;                  % normalize determinant      
      idet = base*base/det; icheck(b,idet,'iinv');
      
         % calculate inverse matrix elements
         
      b11 = a22*idet;       icheck(b,b11,'iinv');
      b12 = -a12*idet;      icheck(b,b12,'iinv');
      b21 = -a21*idet;      icheck(b,b21,'iinv');
      b22 = a11*idet;       icheck(b,b22,'iinv');

         % normalize elements
         
      b.data = [b11 b21 b12 b22] / base;
   else
      error('matrix dimension must be 1 or 2!');
   end
   
   b.margin = b.maxi / max(abs(b.data));
end
