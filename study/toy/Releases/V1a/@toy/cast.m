function obj = cast(obj)
%
% CAST       Cast operator type
%
%               H = toy(1:5);
%               O = operator(H,diag([0 1 1 0 1]);
%               P = cast(O);                       % cast to projector
%
%            See also: TOY, OPERATOR, MTIMES, TIMES, PLUS, MINUS
%
   switch type(obj)
      case '#OPERATOR'
         M = matrix(obj);

         if all(all(M==0))
            return                 % do not cast null matrix
         elseif all(all(M-diag(diag(M)))) == 0 && all(diag(M)==1)
            return                 % do not cast identity matrix
         end
         
         N = M - diag(diag(M));
         
         if all(all(N==0))    % then matrix is diagonal
            labs = labels(obj); 
            list = {};
            d = diag(M);
            for (i=1:length(labs))
               if (d(i) == 1)
                  list{end+1} = labs{i};
               elseif (d(i) ~= 0)
                  return      % cannot cast
               end
            end
            obj = projector(space(obj),list);
         end
   end
   return
end
