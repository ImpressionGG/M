function z = zspace(obj)
%
% ZSPACE    Return z-space of free particle object
%
%              fpo = free(2,-10:0.1:10)       % define free particle object
%              z = zspace(fpo)                % return z coordinates
%
%           Example
%              o = free(2,-10:0.1:10)         % define free particle object
%              plot(zspace(o),eig(o,0:10));   % plot eigen function (0..10)
%
%           See also: FREE
%
   dat = data(obj);
   z = dat.zspace(:);
   return

% eof