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
         [A,B,C] = get(o,'system','A,B,C');
         n = length(A);
         ni = size(B,2);
         no = size(C,1);
      otherwise
         error('type not supported!');
   end
   
   if (nargout <= 1)
      sizes = [n,ni,no];
   end
end