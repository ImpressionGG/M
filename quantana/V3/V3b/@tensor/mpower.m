function out = mpower(obj,n)
% 
% MINUS   Tensor power
%
%             H = space(tensor,1:3);
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
   fmt = format(obj);

   if (nargin < 2)
      error('2 input args expected!');
   end
   
   switch fmt
      case {'#OPERATOR','#SPLIT'}
         if (round(n) ~= n || length(n) ~= 1)
            error('arg2 must be an integer scalar!');
         end
         
         if (n == 0)
            if strcmp(fmt,'#OPERATOR')
               out = eye(obj);                 % identity
               %out = operator(space(obj),1);  % identity
            elseif strcmp(fmt,'#SPLIT')
               out = universe(eye(obj));
            else
               error('bug!');
            end
         else
            out = universe(eye(obj));
            for (i=1:n)
               out = out*obj;
            end
         end
         return
         
      otherwise
         error(['bad format: ',format(obj)]);
   end
end
