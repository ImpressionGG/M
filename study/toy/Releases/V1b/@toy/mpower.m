function out = mpower(obj,n)
% 
% MINUS   Power operator for TOY objects
%
%             H = space(toy,1:3);
%             T = operator(H,magic(3));      % operator on H
%
%         Operator difference
%
%            A = T^0;
%            A = T^1;
%            A = T^n;
%
%         Power of splits
%
%            U = S^3;  % same as U = S*S*S
%
%         See also: TOY, PLUS, MINUS, TIMES, MTIMES, UMINUS, UPLUS
%
   typ = type(obj);

   if (nargin < 2)
      error('2 input args expected!');
   end
   
   switch typ
      case {'#OPERATOR'}
         if (round(n) ~= n || length(n) ~= 1)
            error('arg2 must be an integer scalar!');
         end
         
         out = eye(obj);
         for (i=1:n)
            out = out*obj;
         end
         return

      case {'#SPLIT'}
         if (round(n) ~= n || length(n) ~= 1)
            error('arg2 must be an integer scalar!');
         end
         
         if (n == 0)
            out = universe(eye(obj));
         else
            out = universe(eye(obj));
            for (i=1:n)
               out = out*obj;
            end
         end
         return
         
      otherwise
         error(['bad type: ',type(obj)]);
   end
end
