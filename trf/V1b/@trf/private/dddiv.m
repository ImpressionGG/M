function obj = dddiv(i1,i2,i3,i4,i5,i6,i7,i8,i9)
%
% DDDIV   Data directed division of two or more DD instances.
%
%	     obj = dddiv(obj1)                 % obj = 1 / obj1
%	     obj = dddiv(obj1,obj2)            % obj = obj1/obj2
%	     obj = dddiv(obj1,obj2,obj3,...)   % obj = obj1/obj2/obj3/...
%
%         For one input argument the multiplicative inverse of a DD
%         instance is calculated. If more input arguments are supplied
%         subsequent divisions of the DD instances are calculated.
%
%         See Also: ddclass, ddmagic, ddadd, ddmul, ddsub, dddiv
%
   ilist = ',i1,i2,i3,i4,i5,i6,i7,i8,i9';
   cmd = ['obj=ddcall(''div'',1',ilist(1:nargin*3),');'];
   eval(cmd);

% eof
