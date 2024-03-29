%BLKBUILD Builds a block diagonal state space structure from a block diagram
%	  of transfer functions.
%
% nblocks	is the number of blocks in the diagram.
%
% n1...ni	are the numerator and denominator polynomials for the
%   and		transfer function blocks 1 to i.
% d1...di
%
% a,b,c,d	is the resulting state space structure.  The matrices
%		are built up by progressive parallel additions of the
%		matrix representations of each of the transfer functions.
%
%		See CONNECT for more information.

% Author:  A. Levesque - modified by J.N. Little   8-27-85

[a,b,c,d] = tf2ss(n1,d1);		
for i=2:nblocks
	ii = num2str(i);	% Convert i to string representation
	ii = setstr(ii(1:max(size(ii))-5));
	[aa,bb,cc,dd] = eval(['tf2ss(n',ii,',d',ii,')']);
	[a,b,c,d] = append(a,b,c,d,aa,bb,cc,dd);
end
aa=[];bb=[];cc=[];dd=[];ii=[];i=[];
                                                                                                                                                                           