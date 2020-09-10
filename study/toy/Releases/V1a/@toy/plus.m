function out = plus(ob1,ob2)
% 
% PLUS    toy sum
%
%             S = space(toy,1:3);
%             A = eye(S);                % operator on S
%             B = operator(S,magic(3));  % operator on S
%
%         Operator sum
%
%            C = A+B;
%
%
%         Some short hands
%
%            S+''       % return label matrix
%            S+{}       % return symbol list
%            S+0        % convert to matrix and add number
%
   typ1 = type(ob1);  typ2 = '';
   
   if isa(ob2,'toy')
      typ2 = type(ob2);
   elseif isa(ob2,'double') && ~isempty(ob2)
      out = matrix(ob1) + ob2;
      return
   elseif isa(ob2,'char') && isempty(ob2)
      out = labels(ob1);
      return
   elseif isa(ob2,'cell') && isempty(ob2)
      out = symbols(ob1);
      return
   end
   
% dispatch type of ob1 & ob2

   switch [typ1,typ2]
      case {'#VECTOR#VECTOR'}
         M1 = matrix(ob1);
         M2 = matrix(ob2);

         if any(size(M1)~=size(M2))
            error('sizes do not match!');
         end

         M = M1 + M2;
         out = matrix(ob1,M);
         out = cast(out);
         return

      case {'#OPERATOR#OPERATOR','#PROJECTOR#PROJECTOR',...
            '#PROJECTOR#OPERATOR','#OPERATOR#PROJECTOR'}
         M1 = matrix(ob1);
         M2 = matrix(ob2);

         if any(size(M1)~=size(M2))
            error('sizes do not match!');
         end

         M = M1 + M2;
         obj = operator(space(ob1),0);
         out = matrix(obj,M);
         out = cast(out);
         return
         
   end
   
   error('cannot perform toy sum!');
end
