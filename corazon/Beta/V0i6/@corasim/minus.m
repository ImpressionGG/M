function oo = minus(o1,o2)
%
% MINUS    Overloaded operator - for CORASIM objects
%
%             o1 = system(o,{[1],[2 3]});
%             o2 = system(o,{[1 4],[2 3 5]});
%
%             oo = o1 - o2;            % subtract two trfs
%             oo = o1 - 7;             % subtract real number with trf
%             oo = 5 - o2;             % subtract trf with real number
%
%          Copyright(c): Bluenetics 2020
%
%          See also: CORASIM, PLUS, MINUS, MTIMES, MRDIVIDE
%
   if type(o1,{'fqr'}) && type(o2,{'fqr'})
      oo = FqrSub(o1,o2);
      return
   end

   [o1,o2] = Comply(o1,o2);            % make compliant to each other
   
      % now we are sure to deal with CORASIM objects only

   if (type(o1,{'matrix'}) && ~type(o2,{'matrix'}))
      error('implementation');
      oo = Subtraction(o1,o2);            % matrix + scalar
   elseif (~type(o1,{'matrix'}) && type(o2,{'matrix'}))
      error('implementation');
      oo = Subtraction(o2,o1);            % scalar + matrix
   else
      oo = Sub(o1,o2);
   end

   oo = can(oo);
end

%==========================================================================
% Sub
%==========================================================================

function oo = Sub(o1,o2)               % Subtract Two Objects          
   if ~isequal(o1.type,o2.type)
%     error('type mismatch');
   end
   
   if type(o1,{'szpk','zzpk','qzpk'})
      o1 = trf(o1);
   end
   if ~type(o1,{'strf','ztrf','qtrf'})
      error('bad arg1 type');
   end
   
   if type(o2,{'szpk','zzpk','qzpk'})
      o2 = trf(o2);
   end
   if ~type(o2,{'strf','ztrf','qtrf','szpk','zzpk','qzpk'})
      error('bad arg2 type');
   end
   
   [num1,den1] = peek(o1);
   [num2,den2] = peek(o2);
   
   num1den2 = mul(o1,num1,den2);
   num2den1 = mul(o1,num2,den1);
   
   num = sub(o1,num1den2,num2den1);
   den = mul(o1,den1,den2);
   
   oo = poke(o1,num,den);
end

%==========================================================================
% Subtraction of Scalar With Matrix
%==========================================================================

function o = Subtraction(o,s)          % Subtr. of Matrix and Scalar   
   M = o.data.matrix;
   [m,n] = size(M);
   
   for (i=1:m)
      for (j=1:n)
         M{i,j} = M{i,j} * s;
      end
   end
   o.data.matrix = M;
end

%==========================================================================
% Subtraction of FQR Typed Objects
%==========================================================================

function oo = FqrSub(o1,o2)
    M1 = o1.data.matrix;
    M2 = o2.data.matrix;
    
   [m1,n1] = size(M1);  
   [m2,n2] = size(M2);
   l1 = length(o1.data.omega);
   l2 = length(o2.data.omega);
   
   if (l1~=l2 || m1~=m2 || n1~=n2)
      error('incompatible sizes');
   end
   
      % subtract data
      
   M = M1;
   for (i=1:m1)
      for (j=1:n1)
         M{i,j} = M1{i,j} - M2{i,j};
      end
   end
   
      % store result to out arg
      
   oo = o1;
   oo.data.matrix = M;
end

%==========================================================================
% Make Args Compliant To Each Other
%==========================================================================

function [o1,o2] = Comply(o1,o2)       % Make Compliant to Each Other  
   if ~isa(o1,'corasim')
      o1 = Cast(o1);
      if ~type(o2,{'strf','ztrf','qtrf'})
         error('bad operand type');
      end
      o1.type = o2.type;
      o1.data.T = o2.data.T;
   end
   if ~isa(o2,'corasim')
      o2 = Cast(o2);
      if ~type(o1,{'strf','ztrf','qtrf'})
         error('bad operand type');
      end
      o2.type = o1.type;
      o2.data.T = o1.data.T;
   end
    
   assert(isa(o1,'corasim') && isa(o2,'corasim'));
   
   function oo = Cast(o)               % Cast to Corasim               
      if isa(o,'corasim')
         oo = o;
      elseif isa(o,'double')
         num = o;  den = 1;
         if (size(num,1) ~= 1)
            error('double operand must be scalar or row vector');
         end
         oo = system(corasim,{num,den});
      else
         error('cannot cast operand to CORASIM object');
      end
   end
end
