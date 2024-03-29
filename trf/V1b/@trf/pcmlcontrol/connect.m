function [aa,bb,cc,dd] = connect(a,b,c,d,q,iu,iy)
%CONNECT  Given the block diagram of a system, CONNECT can be used to
%	form an (A,B,C,D) state-space model of the system.
%	[Ac,Bc,Cc,Dc] = CONNECT(A,B,C,D,Q,iu,iy)  returns the state-space
%	model matrices (Ac,Bc,Cc,Dc) of a system given the block diagonal,
%	unconnected (A,B,C,D) matrices and a matrix Q that specifies the
%	interconnections.  The matrix Q has a row for each block, where the
%	first element of each row is the number of the block.  The subsequent
%	elements of each row specify where the block gets its summing inputs,
%	with negative elements used to indicate minus inputs to the summing
%	junction.  For example, if a block 7 gets its inputs from the outputs
%	of blocks 2, 15, and 6, and the block 15 input is negative, the 7'th
%	row of Q would be [7 2 -15 6].   Vectors iu and iy can be used to 
%	select the final inputs and outputs for (Ac,Bc,Cc,Dc). 
%	For more information see a User's Guide.   See also BLKBUILD.

%	Copyright (c) 1985, 1986 by the MathWorks, Inc.
% 	J.N. Little 7-24-85
% 	Last modified JNL 6-2-86

[mq,nq] = size(q);
[md,nd] = size(d); 

% Form k from q, the feedback matrix such that u = k*y forms the
% desired connected system.  k is a matrix of zeros and plus or minus ones.

k = zeros(nd,md);
% Go through rows of Q
for i=1:mq
	% Remove zero elements from each row of Q
	qi = q(i,find(q(i,:)));
	[m,n] = size(qi);
	% Put the zeros and +-ones in K
	if n ~= 1
		k(qi(1),abs(qi(2:n))) = sign(qi(2:n));
	end
end

% Use output feedback to form closed loop system
%	.
%	x = Ax + Bu
%	y = Cx + Du      where  u = k*y + Ur 
%
bb = b/(eye(nd) - k*d);
aa = a + bb*k*c;
t = eye(md) - d*k;
cc = t\c;
dd = t\d;

% Select just the outputs and inputs wanted:
bb = bb(:,iu);
cc = cc(iy,:);
dd = dd(iy,iu);
                                                                                                                                                                                                       