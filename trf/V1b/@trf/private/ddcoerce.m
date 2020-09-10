function [o1,o2,o3,o4,o5,o6,o7,o8,o9]=ddcoerce(fcn,i1,i2,i3,i4,i5,i6,i7,i8,i9)
%
% DDCOERCE   Coerce arguments to instances of the same DD class.
%
%               [arg1,arg2,arg3] = ddcoerce(fcn,arg1,arg2,arg3)
%
%            The first input argument 'fcn' is a string argument speci-
%            fying the calling function which is only used in case of an
%            error messages, which is generated if no coercion is possible.
%

%
% Timing characteristics
%
%    ddcoerce('fcn',a,a,a,a)  ...  61 ms on a 386/33MHz
%    ddcoerce('fcn',a,b,c,d)  ... 151 ms on a 386/33MHz
%

   global ddClasses ddCoercion


   if ( nargin == 1 )
      if ( isstr(fcn) )
         return          % nothing to do if no essential input arguments
      else
         table = fcn;
         ddCoercion = [ddCoercion; table];
         return;
      end
   end


      % determine class handles;  length(class) = nargin > 0


   if ( nargin > 1 )  o1 = i1;  class(1) = ddmagic(i1);  end
   if ( nargin > 2 )  o2 = i2;  class(2) = ddmagic(i2);  end
   if ( nargin > 3 )  o3 = i3;  class(3) = ddmagic(i3);  end
   if ( nargin > 4 )  o4 = i4;  class(4) = ddmagic(i4);  end
   if ( nargin > 5 )  o5 = i5;  class(5) = ddmagic(i5);  end
   if ( nargin > 6 )  o6 = i6;  class(6) = ddmagic(i6);  end
   if ( nargin > 7 )  o7 = i7;  class(7) = ddmagic(i7);  end
   if ( nargin > 8 )  o8 = i8;  class(8) = ddmagic(i8);  end
   if ( nargin > 9 )  o9 = i9;  class(9) = ddmagic(i9);  end


      % if all classes are equal there's nothing more to do


   if ( all(class == class(1)) )
      return;                       % bye!
   end


      % Otherwise we must look for a common class to coerce


   [no_classes,ans] = size(ddClasses);

   candidates = zeros(1,no_classes);

   for (i=1:length(class))
      idx = find (ddCoercion(:,1) == class(i));
      if ( ~isempty(idx) )
         jdx = ddCoercion(idx,2);
         candidates(jdx) = candidates(jdx) + 1;
      end;
   end   


      % select the first candidate with counter equal to length(class)


   idx = find(candidates == length(class));


      % error if there is no such class!


   if ( isempty(idx) )
      msg = ['cannot coerce: ',fcn,'(<',ddclass(class(1)),'>'];
      for (i=2:length(class))
         msg = [msg,',<',ddclass(class(i)),'>'];
      end
      msg = [msg,')'];
      error(msg);
   end

      % otherwise do actual coercion

   prefix = ddClasses(idx(1),:);


   for (i=1:nargin-1)
      eval(['o','0'+i,'=',prefix,'new(i','0'+i,');']);
   end

% eof
