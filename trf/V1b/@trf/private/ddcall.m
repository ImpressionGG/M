function [o1,o2,o3,o4,o5,o6,o7,o8,o9]=ddcall(fcn,coerce,i1,i2,i3,i4,i5,i6,i7,i8,i9)
%
% DDCALL   Data directed function call:
%
%             z = ddcall('add',coerce,x,y)   % data directed addition
%             z = ddcall('mul',coerce,x,y)   % data directed multiplication
%             z = ddcall('disp',coerce,x,y)  % data directed display
%
%          The first argument must be string which specifies the kind of
%          function to be called (e.g. 'add' = addition, 'mul' = multi-
%          plication, 'disp' = display, ...). The second argument 'coerce' 
%          is a flag which specifies whether coercion should be applied to
%          the rest of the arguments. All other input arguments but the
%          first and second are called 'essential input arguments' of the
%          data directed call.
%
%          A data directed call follows a two step scheme:
%
%             Step 1: If coercion is enabled (coerce ~= 0) coerce all 
%                     essential input arguments to DD instances belon-
%                     ging to a common class (coerced class).
%
%             Step 2: Call the actual function whos name is composed by
%                     concatenating the class prefix of the coerced class
%                     with kind of function to be called.
%

%
% timing characteristics:
%    ddcall() without coercion:  53 ms on a 386/33MHz
%    ddcall() with coercion:    191 ms on a 386/33MHz
%

   global ddClasses ddCoercion

   ilist = 'i1,i2,i3,i4,i5,i6,i7,i8,i9';
   olist = 'o1,o2,o3,o4,o5,o6,o7,o8,o9';

   
      % if no essential input args are supplied we have an error


   if ( nargin < 3 )
      error('Data directed calls must have at least one input argument');
   end

   ilist = ilist(1:3*nargin-7);
   olist = olist(1:3*nargout-1);

      % determine class handles;  length(class) = nargin > 0

   class = zeros(1,nargin-2);

   if ( nargin > 2 ) class(1) = ddmagic(i1);  end
   if ( nargin > 3 ) class(2) = ddmagic(i2);  end
   if ( nargin > 4 ) class(3) = ddmagic(i3);  end
   if ( nargin > 5 ) class(4) = ddmagic(i4);  end
   if ( nargin > 6 ) class(5) = ddmagic(i5);  end
   if ( nargin > 7 ) class(6) = ddmagic(i6);  end
   if ( nargin > 8 ) class(7) = ddmagic(i7);  end
   if ( nargin > 9 ) class(8) = ddmagic(i8);  end
   if ( nargin > 10) class(9) = ddmagic(i9);  end


      % if all classes are equal there's nothing more to do
      % Otherwise coercion has to be done


   if ( coerce & any(class ~= class(1)) )
      if ( nargin == 3 )
         [i1] = ddcoerce(fcn,i1);
      elseif ( nargin == 4 )
         [i1,i2] = ddcoerce(fcn,i1,i2);
      elseif ( nargin == 5 )
         [i1,i2,i3] = ddcoerce(fcn,i1,i2,i3);
      elseif ( nargin == 6 )
         [i1,i2,i3,i4] = ddcoerce(fcn,i1,i2,i3,i4);
      elseif ( nargin == 7 )
         [i1,i2,i3,i4,i5] = ddcoerce(fcn,i1,i2,i3,i4,i5);
      elseif ( nargin == 8 )
         [i1,i2,i3,i4,i5,i6] = ddcoerce(fcn,i1,i2,i3,i4,i5,i6);
      elseif ( nargin == 9 )
         [i1,i2,i3,i4,i5,i6,i7] = ddcoerce(fcn,i1,i2,i3,i4,i5,i6,i7);
      elseif ( nargin == 10 )
         [i1,i2,i3,i4,i5,i6,i7,i8] = ddcoerce(fcn,i1,i2,i3,i4,i5,i6,i7,i8);
      elseif ( nargin == 11 )
         [i1,i2,i3,i4,i5,i6,i7,i8,i9] = ddcoerce(fcn,i1,i2,i3,i4,i5,i6,i7,i8,i9);
      end
      
   end

      % All input arguments are of same class - determine prefix

   class = ddmagic(i1);

   if ( class == 0 )
      prefix = 'mat';                % MatLab functions
   else
      prefix = ddClasses(class,:);
   end


   if ( nargout == 0 )
      cmd = [prefix,fcn,'(',ilist,');'];
   else
      cmd = ['[',olist,']=',prefix,fcn,'(',ilist,');'];
   end

   eval(cmd);

% eof

