function y = nargcheck(low,high,number)
% Check number of input arguments. Give error message and return
% 1 if not between low and high.
y = 0;
if (number < low)
	errmsg('Not enough input arguments.')
	y = 1;
elseif (number > high)
	errmsg('Too many input arguments.')
	y = 1;
end
