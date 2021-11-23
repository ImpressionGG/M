function [lambda,Amu] = eig(o,mu)
%
% EIG     Calculate eigenvalues of closed loop system under friction 
%         coefficient mu. Optionally return also closed loop dynamic matrix
%         Amu under feedback with friction coefficient mu.
%
%            [lambda,Amu] = eig(o,mu)         % closed loop eigenvalues
%
%         Copyright(c): Bluenetics 2021
%
%         See also: SPM, STABLE
%
   [A0,B0,C0,D0] = cook(o,'A0,B0,C0,D0');
   
   I = eye(size(D0));
   Amu = A0 - B0 * mu*inv(I-mu*D0) * C0;
   lambda = eig(Amu);
end

