function oo = mtimes(o1,o2)
%
% MTIMES   Overloaded operator * for CORASIM objects
%
%             o1 = system(o,{[1],[2 3]});
%             o2 = system(o,{[1 4],[2 3 5]});
%
%             oo = o1 * o2;            % multiply two trfs
%             oo = o1 * 7;             % multiply real number with trf
%             oo = 5 * o2;             % multiply trf with real number
%
%          Copyright(c): Bluenetics 2020
%
%          See also: CORASIM, PLUS, MINUS, MTIMES, MRDIVIDE
%

      % scalar multiplication is handled specifically to avoid 
      % cancellation at the end of routine, which seems to be not
      % numerically stable
      
   if (isa(o1,'double') || isa(o1,'sym'))  ...
         && length(o1) == 1 && type(o2,{'strf','qtrf','ztrf'})
      [num,den] = peek(o2);
      oo = poke(o2,o1*num,den);
      return
   elseif (isa(o2,'double') || isa(o2,'sym')) ...
         && length(o2) == 1 && type(o1,{'strf','qtrf','ztrf'})
      [num,den] = peek(o1);
      oo = poke(o1,o2*num,den);
      return
   elseif (isa(o1,'double') && type(o2,{'fqr'}))
      [m,n] = size(o2.data.matrix);
      for (i=1:n)
         for (j=1:m)
            o2.data.matrix{i,j} = o1 * o2.data.matrix{i,j};
         end
      end
      oo = o2;
      return
   end      

      % no scalar - proceed with the generic algorithm
      
   [o1,o2] = Comply(o1,o2);            % make compliant to each other
   
      % now we are sure to deal with CORASIM objects only

   if (type(o1,{'matrix'}) && ~type(o2,{'matrix'}))
      error('implementation');
      oo = Multiply(o1,o2);            % matrix * scalar
   elseif (~type(o1,{'matrix'}) && type(o2,{'matrix'}))
      error('implementation');
      oo = Multiply(o2,o1);            % scalar * matrix
   else
      oo = Mul(o1,o2);
   end

   oo = can(oo);
end

%==========================================================================
% Multiply
%==========================================================================

function oo = Mul(o1,o2)               % Multiply Two Objects          
   %if (type(o1,{'szpk','zzpk','qzpk'}) && order(o2) == 0)
   %   o2 = trf(o2,{[],[],gain(o2)},o2.data.T);
   %elseif (type(o2,{'szpk','zzpk','qzpk'}) && order(o1) == 0)
   %   o1 = trf(o1,{[],[],gain(o1)},o1.data.T);
   %end

   if ~isequal(o1.type,o2.type)
      if type(o1,{'szpk','zzpk','qzpk'})
         o1 = trf(o1);                 % cast to TRF
      end
      if type(o2,{'szpk','zzpk','qzpk'})
         o2 = trf(o2);                 % cast to TRF
      end
      if ~isequal(o1.type,o2.type)     % final trial
         error('type mismatch');
      end
   end
   
   if type(o1,{'strf','ztrf','qtrf'})   
   
      [num1,den1] = peek(o1);
      [num2,den2] = peek(o2);

      num = mul(o1,num1,num2);
      den = mul(o1,den1,den2);

      oo = poke(o1,num,den);

   elseif type(o1,{'szpk','zzpk','qzpk'})
      
      if ~isequal(o1.data.T,o2.data.T)
         error('sampling time mismatch');
      end
      
      [z1,p1,K1] = zpk(o1);
      [z2,p2,K2] = zpk(o2);
      
      oo = zpk(o1,[z1;z2],[p1;p2],K1*K2);
      
   else
      error('bad arg type');
   end
end

%==========================================================================
% Multiply Scalar With Matrix
%==========================================================================

function o = Multiply(o,s)             % Multiply Matrix by Scalar     
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
% Make Args Compliant To Each Other
%==========================================================================

function [o1,o2] = Comply(o1,o2)       % Make Compliant to Each Other  
   if ~isa(o1,'corasim')
      o1 = Cast(o1,o2);
      if ~type(o1,{'strf','ztrf','qtrf'})
         error('bad operand type');
      end
      o1.data.T = o2.data.T;           % inherit sampling time

      if type(o2,{'szpk','zzpk','qzpk'})
         o1 = zpk(o1);                 % convert to ZPK
      end
   end
   if ~isa(o2,'corasim')
      o2 = Cast(o2,o1);
      if ~type(o2,{'strf','ztrf','qtrf'})
         error('bad operand type');
      end
      o2.data.T = o1.data.T;           % inherit sampling time
      
      if type(o1,{'szpk','zzpk','qzpk'})
         o2 = zpk(o2);                 % convert to ZPK
      end
   end
    
   assert(isa(o1,'corasim') && isa(o2,'corasim'));
   
   function oo = Cast(o,obj)           % Cast to Corasim               
   %
   % CAST  Cast numerical item o to a corasim object, occasionally copy
   %       verbose option from arg2
   %
   %          oo = Cast(o);            % simple casting
   %          oo = cast(o,obj);        % verbose option provided by obj
   %
      if isa(o,'corasim')
         oo = o;
      elseif (isa(o,'double') || isa(o,'sym'))
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
