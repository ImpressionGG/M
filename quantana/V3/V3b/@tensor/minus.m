function out = minus(ob1,ob2)
% 
% MINUS   Tensor difference
%
%             S = space(tensor,1:3);
%             A = eye(S);                % operator on S
%             B = operator(S,magic(3));  % operator on S
%
%         Operator difference
%
%            C = A-B;
%
%         Some short hands
%
%            S-[]       % return labels
%            S-0        % convert to matrix and add number
%
   fmt1 = format(ob1);  fmt2 = '';
   
   if isa(ob2,'tensor')
      fmt2 = format(ob2);
   elseif isa(ob2,'double')
      if isempty(ob2)
         out = labels(ob1);
      else
         out = matrix(ob1) - ob2;
      end
      out = cast(out);
      return
   end
   
% dispatch format of ob1

   switch [fmt1,fmt2]
      case {'#OPERATOR#OPERATOR','#OPERATOR#PROJECTOR',...
            '#PROJECTOR#OPERATOR','#PROJECTOR#PROJECTOR','#VECTOR#VECTOR'}
         M1 = matrix(ob1);
         M2 = matrix(ob2);

         if any(size(M1)~=size(M2))
            error('sizes do not match!');
         end

         M = M1 - M2;
         out = matrix(ob1,M);
         out = cast(out);
         return
   end
   
   error('cannot perform tensor sum!');
end
