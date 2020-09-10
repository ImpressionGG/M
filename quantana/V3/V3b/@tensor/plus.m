function out = plus(ob1,ob2)
% 
% PLUS    Tensor sum
%
%             S = space(tensor,1:3);
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
%            S+''       % return labels
%            S+0        % convert to matrix and add number
%
   fmt1 = format(ob1);  fmt2 = '';
   
   if isa(ob2,'tensor')
      fmt2 = format(ob2);
   elseif isa(ob2,'double') && ~isempty(ob2)
      out = matrix(ob1) + ob2;
      %out = cast(out);
      return
   elseif isa(ob2,'char') && isempty(ob2)
      out = labels(ob1);
      %out = cast(out);
      return
   end
   
% dispatch format of ob1

   switch [fmt1,fmt2]
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
   
   error('cannot perform tensor sum!');
end
