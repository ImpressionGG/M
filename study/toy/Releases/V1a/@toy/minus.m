function out = minus(ob1,ob2)
% 
% MINUS   Difference operator for TOY objects
%
%    Syntax
%       H = space(toy,1:3);
%       A = eye(H);                   % operator on H
%       B = operator(H,magic(3));     % operator on H
%
%    Operator difference
%
%       C = A-B;
%
%    Some short hands
%
%       S-[]          % return labels
%       S-0           % convert to matrix and add number
%
%    See also: TOY, SPACE, PLUS, TIMES, MTIMES, MPOWER
%
   typ1 = type(ob1);  typ2 = '';
   
   if isa(ob2,'toy')
      typ2 = type(ob2);
   elseif isa(ob2,'double')
      if isempty(ob2)
         out = labels(ob1);
      else
         out = matrix(ob1) - ob2;
      end
      out = cast(out);
      return
   end
   
% dispatch type of ob1 & ob2

   switch [typ1,typ2]
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
   
   error('cannot perform toy sum!');
end
