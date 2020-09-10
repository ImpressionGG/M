function z = zspace(obj)
%
% ZSPACE    Return z-space of a quon object
%
%              eob = envi(quantana,'box');  % particle in a box environment
%              qob = quon(eob,1)            % define quon in ground state
%              z = zspace(qob)              % return z coordinates
%
%           See also: QUANTANA, QUON, EIG
%
   dat = data(obj);
   z = dat.zspace(:);
   return

% eof