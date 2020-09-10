function obj = ddsub(i1,i2,i3,i4,i5,i6,i7,i8,i9)
%
% DDSUB   Data directed subtraction of two or more DD instances.
%
%	     obj = ddsub(obj1)                 % obj = -obj1
%	     obj = ddsub(obj1,obj2)            % obj = obj1-obj2
%	     obj = ddadd(obj1,obj2,obj3,...)   % obj = obj1-obj2-obj3-...
%
%         For one input argument negation of a DD instance is calculated.
%         If more input arguments are supplied the second, third, etc. 
%         DD instances are subtracted from the first.
%
%         See Also: ddclass, ddmagic, ddadd, ddmul, ddsub, dddiv
%
   ilist = ',i1,i2,i3,i4,i5,i6,i7,i8,i9';
   cmd = ['obj=ddcall(''sub'',1',ilist(1:nargin*3),');'];
   eval(cmd);

% eof
