function [o1,o2] = form(o,x,y,m)      % Form to Sizes of Operands       
%
% FORM    Adjust sizes of two mantissas to achieve matching sizes
%         and optionally add m leading zeros
%
%            oo = form(o)             % form to get zero exponent
%
%            [x,y] = form(o,x,y)
%            [x,y] = form(o,x,y,0)    % same as above
%            [x,y] = form(o,x,y,m)    % additionally add n leading zeros 
%       
%         See also: CORINTH, NEW, TRIM
%   
   if (nargin == 1)                % form to get zero exponent      
      switch o.type
         case 'number'
            o1 = FormNumber(o);
         case 'poly'
            o1 = FormPoly(o);
         otherwise
            error('implementation restriction');
      end
   elseif (nargin >= 3 && ~isobject(x))
      if (nargin < 4)
         m = 0;
      end
      [o1,o2] = Form(o,x,y,m,0);
   end
end

%==========================================================================
% Form Mantissa
%==========================================================================

function [x,y] = Form(o,x,y,m,e)
   if (m < 0)
      error('number of extra zeros (arg4) must be non-negative!');
   end

   if (e > 0)
      x = [x,zeros(1,e)];
   elseif (e < 0)
      y = [y,zeros(1,-e)];
   end
   
   nx = length(x);
   ny = length(y);
   n = max(nx,ny);

   x = [zeros(1,n-nx+m),x];
   y = [zeros(1,n-ny+m),y];
end

%==========================================================================
% Form Ratio
%==========================================================================

function o = FormNumber(o)             % Form Number                   
   d = o.data;  expo = d.expo;  num = d.num;  den = d.den;

   if (expo > 0)
      num = [num,zeros(1,expo)];
   elseif (expo < 0)
      den = [den,zeros(1,-expo)];
   end
   o.data.expo = 0;

   nn = length(num);  
   nd = length(den);
   n = max(nn,nd);

   o.data.num = [zeros(1,n-nn),num];
   o.data.den = [zeros(1,n-nd),den];
end

%==========================================================================
% Form Poly
%==========================================================================

function o = FormPoly(o)               % Form Polynomial               
   data = o.data;  
   expo = data.expo;  num = data.num;  den = data.den;
   data.num = [];  data.den = [];

   for (i=1:length(expo))
      [x,y] = Form(o,num(i,:),den(i,:),0,expo(i));
      data.expo(i) = 0;
      data.num(i,1:length(x)) = x;
      data.den(i,1:length(y)) = y;
   end
   o.data = data;
end