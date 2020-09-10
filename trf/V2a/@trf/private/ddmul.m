function obj = ddmul(i1,i2,i3,i4,i5,i6,i7,i8,i9)
%
% DDMUL   Data directed multiplication of two or more DD instances.
%
%	     obj = ddmul(obj1,obj2)            % obj=obj1*obj2
%            obj = ddmul(obj1,obj2,obj3,...)   % obj=obj1*obj2*obj3*...
%
%	  Calculates the product of instances obj1 and obj2. Up to nine
%         instances may be multiplied.
%
%         See Also: ddclass, ddmagic, ddadd, ddmul, ddsub, dddiv
%
   ilist = ',i1,i2,i3,i4,i5,i6,i7,i8,i9';
   cmd = ['obj=ddcall(''mul'',1',ilist(1:nargin*3),');'];
   eval(cmd);

% eof
