function X = lyap(A, B, C)
%LYAP	Lyapunov equation.
%	X = LYAP(A,C) solves the special form of the Lyapunov matrix equation:
%
%		A*X + X*A' = -C
%
%	X = LYAP(A,B,C) solves the general form of the Lyapunov matrix
%	equation:
%
%		A*X + X*B = -C
%
%	See also DLYAP.

% Author: S. Bangert 1-10-86

	if nargin == 2
		C = B;
		B = A';
	end
	[ma,na] = size(A);
	[mb,nb] = size(B);
	[mc,nc] = size(C);

	if (ma ~= na) | (mb ~= nb) | (mc ~= ma) | (nc ~= mb)
		 errmsg('Inconsistant inputs to LYAP')
		return
	end

% check if problem has any complex inputs
	if any(any(imag(A))) | any(any(imag(B))) | any(any(imag(C)))
		real_flg = 0;
	else
		real_flg = 1;
	end

% perform schur decomposition on A and B (note: complex schur form forced by
% adding small complex part so ua and ub are complex upper triangular)
	i = sqrt(-1);
	[ua,ta] = schur(A+eps*eps*i*A);
	[ub,tb] = schur(B+eps*eps*i*B);

% check all combinations of ua(i,i)+ub(j,j) for zero
	p1 = ones(mb,1)*diag(ta)';
	p2 = diag(tb)*ones(1,ma);
	sum = abs((p1 + p2)./(abs(p1) + abs(p2)));
	if any(any(sum < 1000*eps)) | any(any(sum == NaN))
		errmsg('Insoluble problem for LYAP')
		return
	end

% transform C
	ucu = -ua'*C*ub;

% solve for first column of transformed solution
	y(ma,mb)=0;
	ema = eye(ma,ma);
	y(:,1) = (ta+ema*tb(1,1))\ucu(:,1);

% solve for remaining columns of transformed solution
	for k=2:mb
		km1 = 1:(k-1);
		y(:,k) = (ta+ema*tb(k,k))\(ucu(:,k)-y(:,km1)*tb(km1,k));
	end

% find untransformed solution 
	X = ua*y*ub';

% ignore complex part if real inputs (better be small)
	if real_flg
		X = real(X);
	end
                                                                                                                                                                                                                                                                                                                                                                                                              