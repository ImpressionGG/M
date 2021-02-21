function [n,ni,no] = size(o)
%
% SIZE     Get sizes of a system
%
%             [n,ni,no] = size(o)      % get system sizes
%             sizes = size(o)          % return sizes = [n,ni,no]
%
%           where:
%              n:   system order (dimension of state vector)
%              ni:  input vector size
%              no:  output vector size
%
%          See also: CORASIM
%
   switch type(o)
      case {'css','dss'}
         [A,B,C] = data(o,'A,B,C');
         n = length(A);
         ni = size(B,2);
         no = size(C,1);
 
      case 'modal'
         [a0,B,C] = data(o,'a0,B,C');
         n = 2*length(a0);
         ni = size(B,2);
         no = size(C,1);
         
      case 'matrix'
         if (nargout <= 2)
            [n,ni] = size(o.data.matrix);
         else
            error('only 2 out args supported');
         end
         
      case {'strf','ztrf','qtrf'}
         n = length(den(o));
         ni = 1; no = 1;
         
      case 'fqr'
         n = o.data.n;
         [no,ni] = size(o.data.matrix);
         
      otherwise
         error('type not supported!');
   end
   
   if (nargout <= 1)
      sizes = [n,ni,no];
      n = sizes;
   end
end