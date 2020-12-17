function oo = plus(o1,o2)
%
% PLUS     Overloaded operator + for CORASIM objects
%
%             o1 = system(o,{[1],[2 3]});
%             o2 = system(o,{[1 4],[2 3 5]});
%
%             oo = o1 + o2;            % add two trfs
%             oo = o1 + 7;             % add real number with trf
%             oo = 5 + o2;             % add trf with real number
%
%          Options:
%
%             digits         number of digits for variable precision
%                            arithmetics (symbolic toolbox required)
%                            (default: 0, no VPA!)
%
%          Copyright(c): Bluenetics 2020
%
%          See also: CORASIM, PLUS, MINUS, MTIMES, MRDIVIDE
%
   [o1,o2] = Comply(o1,o2);            % make compliant to each other
   
      % now we are sure to deal with CORASIM objects only

   if type(o1,{'modal'}) && type(o2,{'modal'})
      oo = ModalAdd(o1,o2);
      return
   elseif type(o1,{'szpk','zzpk','qzpk'}) && type(o2,{'szpk','zzpk','qzpk'})
      oo = ZpkAdd(o1,o2);
      return
   elseif (type(o1,{'matrix'}) && ~type(o2,{'matrix'}))
      error('implementation');
      oo = Addition(o1,o2);            % matrix + scalar
   elseif (~type(o1,{'matrix'}) && type(o2,{'matrix'}))
      error('implementation');
      oo = Addition(o2,o1);            % scalar + matrix
   else
      oo = Add(o1,o2);
   end

   oo = can(oo);
end

%==========================================================================
% Add
%==========================================================================

function oo = Add(o1,o2)               % Add Two Objects               
   if ~isequal(o1.type,o2.type)
      error('type mismatch');
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
   if ~type(o2,{'strf','ztrf','qtrf'})
      error('bad arg2 type');
   end
   
      % peek numerator/denominator
      
   [num1,den1] = peek(o1);
   [num2,den2] = peek(o2);
 
      
      % Variable precision arithmetics (VPA) required?
         
   digs = opt(o1,{'digits',0});
   if (digs > 0)
      digits(digs);
      num1 = vpa(num1);  den1 = vpa(den1);
      num2 = vpa(num2);  den2 = vpa(den2);
   end
  
   num1den2 = mul(o1,num1,den2);
   num2den1 = mul(o1,num2,den1);
   
   num = add(o1,num1den2,num2den1);
   den = mul(o1,den1,den2);
   
   oo = poke(o1,num,den);
end

%==========================================================================
% Modal Add
%==========================================================================

function oo = ModalAdd(o1,o2)          % Add Two Objects               
   if ~isequal(o1.type,o2.type)
      error('type mismatch');
   end
   if ~type(o1,{'modal'})
      error('bad arg1 type');
   end
   if ~type(o2,{'modal'})
      error('bad arg2 type');
   end
   
   [a01,a11,B1,C1,D1] = data(o1,'a0,a1,B,C,D');
   n1 = length(a01);  i11 = 1:n1;  i12 = n1+1:2*n1;
   
   [a02,a12,B2,C2,D2] = data(o2,'a0,a1,B,C,D');
   n2 = length(a02);  i21 = 1:n2;  i22 = n2+1:2*n2;
   
   if any(size(D1)~=size(D2))
      error('number of inputs and outputs must be the same');
   end
   
   a0 = [a01;a02];  a1 = [a11;a12];
   B = [B1(i11,:);B2(i21,:); B1(i12,:);B2(i22,:)];
   C = [C1(:,i11),C2(:,i21), C1(:,i12),C2(:,i22)];
   D = D1+D2;
   
   oo = modal(o1,a0,a1,B,C,D);
end

%==========================================================================
% ZPK Add
%==========================================================================

function oo = ZpkAdd(o1,o2)            % Add Two ZPK Objects           
   if ~isequal(o1.type,o2.type)
      error('type mismatch');
   end
   if ~type(o1,{'szpk','zzpk','qzpk'})
      error('bad arg1 type');
   end
   if ~type(o2,{'szpk','zzpk','qzpk'})
      error('bad arg2 type');
   end

      % start with initial out arg oo
      
   oo = o1;  oo.data.zeros = [];  oo.data.poles = [];  oo.data.K = 0;
   oo.par.name = '';

   data1 = o1.data;  data2 = o2.data;
   K1 = data1.K;
   K2 = data2.K;
   
   z12 = [data1.zeros; data2.poles];
   z21 = [data2.zeros; data1.poles];
   p = [data1.poles; data2.poles];
   
      % cancelling
      
   [p,z12,z21] = Cancel(oo,p,z12,z21);
   
   [z,K] = Zeros(oo,z12,z21); % numerator roots
      
   oo.data.zeros = z;
   oo.data.poles = p;
   oo.data.K = K;
 
   function [z,K] = Zeros(o,z12,z21)       % Numerator Roots & K           
      digs = opt(o,{'digits',0});
      
         % Variable precision arithmetics (VPA) required?
         
      if (0 && digs > 0)
         digits(digs);
         z12 = vpa(z12);  z21 = vpa(z21);
      end
      
      poly12 = polynom(oo,z12);
      poly21 = polynom(oo,z21);
      
      num1den2 = K1 * poly12;
      num2den1 = K2 * poly21;
      
      num = Sum(num1den2,num2den1);
      
      if ~all(isfinite(num))
         'action!';
      end

      z = roots(num);
      K = num(1);
      
        % convert back from VPA to double
        
      z = double(z);
      K = double(K);
   end
   function z = Sum(x,y)               % Sum of Two Polynomials        
      nx = length(x);  ny = length(y);  n = max(nx,ny);
      z = [zeros(1,n-nx),x] + [zeros(1,n-ny),y]; 
      z = Trim(z);
   end
   function p = Trim(p)                % Trim Polynomial               
      idx = find(p~=0);
      if isempty(idx)
         p = 0;
      else
         p = p(idx(1):end);
      end
   end
   function [r1,r2,r3] = Cancel(o,r1,r2,r3)  % Root Cancelation        
      caneps = opt(o,{'eps',eps});
      
      n1 = length(r1);  n2 = length(r2);  n3 = length(r3);
      if (n1 <= n2 && n1 <= n3)
         r = r1;
      elseif (n2 <= n1 && n2 <= n3)
         r = r2;
      else
         r = r3;
      end
      
      for (i = 1:length(r))
         ri = r(i);
         
         d1 = abs(ri-r1);  d(1) = min(d1);
         d2 = abs(ri-r2);  d(2) = min(d2);
         d3 = abs(ri-r3);  d(3) = min(d3);

            % cancel ?
            
         delta = max(d) / o.iif(ri==0,1,abs(ri));   % relative distance
         if (delta < caneps)
            Trace(o,ri,delta);         % trace cancellation
            idx1 = find(d1 == d(1));
            idx2 = find(d2 == d(2));
            idx3 = find(d3 == d(3));
         
            r1(idx1(1)) = [];
            r2(idx2(1)) = [];
            r3(idx3(1)) = [];
         end
      end
   end
   function Trace(o,ri,delta)          % Trace Cancellation            
      if (control(o,'verbose') > 0)
         if (imag(ri) > 0)
            fprintf('   cancel %g + %gi (delta: %g)\n',...
                    real(ri),imag(ri),delta);
         elseif (imag(ri) < 0)
            fprintf('   cancel %g - %gi (delta: %g)\n',...
                    real(ri),-imag(ri),delta);
         else
            fprintf('   cancel %g (delta: %g)\n',real(ri),delta);
         end
      end
   end
end

%==========================================================================
% Addition of Scalar With Matrix
%==========================================================================

function o = Addition(o,s)             % Addition of Matrix by Scalar  
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
% Make Args Compiant To Each Other
%==========================================================================

function [o1,o2] = Comply(o1,o2)       % Make Compliant to Each Other  
   if ~isa(o1,'corasim')
      o1 = Cast(o1,o2);
      if type(o2,{'szpk','zzpk','qzpk'})
         o2 = trf(o2);                 % cast to trf
      end
      if ~type(o2,{'strf','ztrf','qtrf'})
         error('bad operand type');
      end
      o1.type = o2.type;
      o1.data.T = o2.data.T;
   end
   if ~isa(o2,'corasim')
      o2 = Cast(o2,o1);
      if type(o1,{'szpk','zzpk','qzpk'})
         o1 = trf(o1);                 % cast to trf
      end
      if ~type(o1,{'strf','ztrf','qtrf'})
         error('bad operand type');
      end
      o2.type = o1.type;
      o2.data.T = o1.data.T;
   end
    
   assert(isa(o1,'corasim') && isa(o2,'corasim'));
   
   function oo = Cast(o,obj)           % Cast to Corasim               
      if isa(o,'corasim')
         if type(o,{'szpk','zzpk','qzpk'})
            oo = trf(o);               % cast
         else
            oo = o;
         end
      elseif isa(o,'double')
         num = o;  den = 1;
         if (size(num,1) ~= 1)
            error('double operand must be scalar or row vector');
         end
         oo = system(corasim,{num,den});
         if (nargin >= 2 && isa(obj,'corazon'))
            oo = control(oo,'verbose',control(obj,'verbose'));
         end
      else
         error('cannot cast operand to CORASIM object');
      end
   end
end
