function out = mtimes(ob1,ob2)
% 
% TIMES    Tensor multiplication
%
%             S1 = space(tensor,'a','b','c');
%             S2 = space(tensor,1:3);
%
%          Universe multiplication
%
%             H = space(tensor,1:5);
%             S1 = split(H,{'1','*'});
%             S2 = split(H,{'2','*'});
%             S3 = split(H,{'3','*'});
%
%             U = S1*S2;
%             U = U*S3;
%
%          Bra-Ket Product of histories: let Y1,Y2 be histories
%
%               chain(Y1)'*chain(Y2)  % check orthogonality
%               Y1'*Y2                % same as above (short hand)
%
   if isa(ob1,'double')
      tmp = ob1;  ob1 = ob2;  ob2 = tmp;    % swap ob1<->ob2
   end
   
   fmt1 = format(ob1);
   
   if isa(ob2,'tensor')
      fmt2 = format(ob2);
   elseif isa(ob2,'double')
      fmt2 = '#DOUBLE';
   else
      fmt2 = '';
   end
   
   switch [fmt1,fmt2]
      case '#VECTOR#VECTOR'
         M1 = matrix(ob1);
         M2 = matrix(ob2);

         [m1,n1] = size(labels(ob1));
         [m2,n2] = size(labels(ob2));
         
         dim1 = dim(ob1);
         dim2 = dim(ob2);
         
         if (dim1 ~= dim2)
            error('incompatible dimensions!');
         end
         
         if (property(ob1,'bra') && property(ob2,'ket'))
            M2 = M2.';
            M = M1(:).' * M2(:);
            out = M+0;             % dot product
         elseif (property(ob1,'ket') && property(ob2,'bra'))
            M2 = M2.';
            M = M1(:) * M2(:).';
            S = space(ob1);
            out = operator(S,'null');
            out = matrix(out,M);
         end
         out = cast(out);
         return

      case {'#OPERATOR#VECTOR','#PROJECTOR#VECTOR'}
         M = matrix(ob1);
         v = matrix(ob2);

         if any(size(labels(ob1)) ~= size(labels(ob2)))
            error('incompatible sizes!');
         end

         if any(size(M,2)~=size(v(:),1))
            error('sizes do not match!');
         end

         V = M*v(:);
         V = reshape(V,size(v));
         out = matrix(ob2,V);
         out = cast(out);
         return
         
      case {'#OPERATOR#OPERATOR','#PROJECTOR#PROJECTOR',...
            '#PROJECTOR#OPERATOR','#OPERATOR#PROJECTOR'}
         M1 = matrix(ob1);
         M2 = matrix(ob2);

         if any(size(M1)~=size(M2))
            error('sizes do not match!');
         end

         M = M1*M2;
         obj = operator(space(ob1),0);
         out = matrix(obj,M);
         out = cast(out);
         return

      case {'#OPERATOR#DOUBLE','#PROJECTOR#DOUBLE','#VECTOR#DOUBLE'}
         M1 = matrix(ob1);
         S = ob2;

         M = M1*S;
         out = matrix(ob1,M);
         out = cast(out);
         return

      case '#OPERATOR#UNIVERSE'
         if ~property(ob1,'unitary')
            error('arg1 must be a unitary operator!');
         end
         
         T = property(ob2,'transition');   % get transition operator
         U = universe(ob1*T);              % new universe
         uni = data(ob2,'uni');
         U = data(U,'uni',uni);
         out = cast(out);
         out = U;
         
      case '#OPERATOR#SPLIT'
         if ~property(ob1,'unitary')
            error('arg1 must be a unitary operator!');
         end
         
         U = universe(ob1);
         U = universe(U,ob2);
         out = cast(out);
         out = U;
         
      case '#SPLIT#SPLIT'
         U = universe(eye(ob1));   %create universe
         U = universe(U,ob1);
         U = universe(U,ob2);
         out = U;
         
      case '#UNIVERSE#SPLIT'
         out = universe(ob1,ob2);

      case '#HISTORY#HISTORY'
         if ~(property(ob1,'bra') && property(ob2,'ket'))
            error('<history bra| expected for arg1 and |history ket> for arg2!');
         end
         
         K1 = chain(ob1');
         K2 = chain(ob2);
         out = K1'*K2;
         
   end
   out = cast(out);
   return
   
   error('cannot perform tensor sum!');
end
