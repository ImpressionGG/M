function [out1,out2] = drift(list,xy)
%
% DRIFT   Drift of a list of matrices
%
%             [Xd,Yd] = drift({V1,V2,...,Vn})   % drift of list of vector sets
%             Xd = drift({V1,V2,...,Vn},1)      % x drift of list of vector sets
%             Yd = drift({V1,V2,...,Vn},2)      % y drift of list of vector sets
%             Xd = drift({X1,X2,...,Xn})        % drift of list of matrices
%             Vd = drift(V)                     % drift of a 1D,2D, ..., nD vector set 
%
%         See also: SMART FILTER1D FILTER2D
%
   if (~iscell(list))
      if (nargin > 1)
         error('only one input arg expected, if arg1 is not a list!');
      end
      V = list;
      [m,n] = size(V);
      Vd = V - V(:,1)*ones(1,n);
      out1 = Vd;
      return
   end
   
% handle list input arg

   M1 = list{1};
   [m,n] = size(M1);
   
   if (nargout < 2 & nargin < 2)
      Xd = zeros(length(list),m*n);
   
      for (i=1:length(list))
         Mi = list{i};
         Di = Mi - M1;    
         Xd(i,:) = Di(:)';    
      end
      out1 = Xd;
      return
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   if (nargout == 2 | nargin == 2)
      if (m~=2) error('vector sets expected!'); end
      if (nargin == 2)
         if (~(xy == 1 | xy == 2)) error('arg2 must be 1 or 2!'); end
      end
      
      Xd = zeros(length(list),n);
      Yd = zeros(length(list),n);
   
      for (i=1:length(list))
         Mi = list{i};
         Xd(i,:) = Mi(1,:) - M1(1,:);    
         Yd(i,:) = Mi(2,:) - M1(2,:);
      end
      
      if (nargout == 2)
         out1 = Xd;  out2 = Yd;
      elseif (xy == 1)
         out1 = Xd;
      elseif (xy == 2)
         out1 = Yd;
      else
         error('bug!');
      end
      return
   end
   