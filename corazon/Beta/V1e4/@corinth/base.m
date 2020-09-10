function o = base(o,number)            % Set Basis of CORINTH Object   
%
% BASE    Set basis of a rational object
%
%            o = base(corinth);        % set default basis 1e6
%
%            o = base(corinth,10);     % set basis 10          
%            o = base(corinth,1000);   % set basis 1000          
%            o = base(corinth,1e6);    % set basis 1e6          
%
%         See also: CORINTH, TRIM, NEW
%
   if (nargin < 2)
      number = 1e6;
   end
   
   o.data.base = number;
end
