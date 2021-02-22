function oo = matrix(o,M)              % Construct Corasim Matrix      
%
% MATRIX Construct a matrix of corasim objects
%
%           oo = matrix(corasim)       % create empty corasim matrix
%           oo = matrix(o,M)           % create corasim matrix from M
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORASIM, SYSTEM
%
   if (nargin == 1)
      M = {};
   end
   
   oo = Matrix(o,M);
end

%==========================================================================
% Rational Matrix Construction
%==========================================================================

function oo = Matrix(o,M)              % Construct CORASIM Matrix      
   oo = corasim('matrix');
   oo.data.matrix = M;
end

