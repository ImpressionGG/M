function out = mrdivide(ob1,ob2)
% 
% MRDIVIDE   Right division operator for TOY objects
%
%    Operator division by a scalar
%
%       I = toy(1:5,'eye')          % create an identity operator
%       D = I/2;                    % right divison by scalar
%
%    Bra/Ket right division by scalar
%
%       H = space(toy,1:5)          % create a Hilbert space
%       ket = H('2');               % ket vector with label '2'
%       V = ket/sqrt(2);            % ket division by scalar
%
%       bra = H('3')';              % bra vector with label '3'
%       V = bra/2;                  % bra division by scalar
%
%    See also: TOY, PLUS, MINUS, TIMES, MPOWER
%
   [typ1,typ2] = Types(ob1,ob2);
   
   switch [typ1,typ2]
      case {'#VECTOR#DOUBLE','#OPERATOR#DOUBLE'}
         M1 = matrix(ob1);
         M2 = ob2;

         M = M1/M2;
         obj = matrix(ob1,M);
         out = cast(obj);
         return

      case {'#PROJECTOR#DOUBLE'}
         M1 = matrix(ob1);
         M2 = ob2;

         M = M1/M2;

         obj = operator(space(ob1),0);
         obj = matrix(obj,M);
         out = cast(obj);
         return
         
   end
   
   error('cannot perform right division for a toy object!');
end

%==========================================================================
% Get Types of Arguments
%==========================================================================

function [typ1,typ2] = Types(ob1,ob2)
%
% TYPES   Get types of arguments
%
   typ1 = type(ob1);
   
   if isa(ob2,'toy')
      typ2 = type(ob2);
   elseif isa(ob2,'double')
      typ2 = '#DOUBLE';
   else
      typ2 = '#???';
   end
   return
end
