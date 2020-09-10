function C = com(A,B)
%
% COM        Calculaate the commutator C of two operators A,B
%            
%               C = com(A,B);    % C = [A,B] = A*B - B*A
%
%            The operators A,B are commuting if their commutator C = [A,B]
%            is the null operator.
%
%            See also: TENSOR, OPERATOR
%
   C = A*B - B*A;
   return
end