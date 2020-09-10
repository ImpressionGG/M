function [class,kind,sign] = ddmagic(arg1,arg2)
%
% DDMAGIC    Compose or decompose a magic tag.
%
%            Within the data directed environment (DD) matrices are reco-
%            gnized as DD-objects if the first element of a matrix is a 
%            magic tag which contains class, kind and sign information.
%            A magic tag is composed by the formula
%
%               magic_tag = sign * (magic + class*100 + kind)
%
%            where
%
%               magic:  =0.3562951413      (10 digits of Pi in reverse order)
%               class:  A number (1..999) specifying a class
%               kind:   A number specifying a specific kind of a class
%               sign:   The value +1 or -1 (object's sign information)
%
%            Function ddmagic() is used to detect, decompose and compose
%            magic tags.
%
%
%            a) Detect and decompose a magic tag: Check if matrix has a magic
%               tag in its upper left corner. If yes extract class, size and 
%               sign information. If no return zeros for class and kind and
%               1 for sign.
%
%                  [class,kind,sign] = ddmagic(object)
%
%
%            b) Compose a magic tag from class and kind.
%
%                  magic_tag = ddmagic(class,kind);
%
%
%            c) To return the value of magic (10 digits from Pi in reverse 
%               order) invoke ddmagic without input arguments.
%
%                  magic_number = ddmagic
%
%               which is equivalent to
%
%                  magic_number = ddmagic(0,0)
%
%            See Also: DD, DDSETUP
%

%
% Notes about execution time: This function needs 6.2 ms to decompose an tag
% on a 486/66MHz CPU.
%

   magic = 0.3562951413;     % first 10 digits from Pi in reverse order
   sign = 1;

   if ( nargin == 1 )

      if ( isempty(arg1) )
         % return zero values       % see end of function
      else      
         tag = arg1(1);
         xmag = round(1e10*rem(tag,1));
         %xmag = round(1e10*mod(tag,1));
         xmagic = round(magic*1e10);
         if ( xmag == xmagic )
            class = tag/100;
            kind  = fix(100*rem(class,1));
            class = fix(class);
            return;
         elseif ( xmag == -xmagic )
            tag = -tag;  sign = -1;
            class = tag/100;
            kind  = fix(100*rem(class,1));
            class = fix(class);
            return;
         end
      end

   elseif ( nargin == 2 )

      class = magic + arg1*100 + arg2;    % magic + class*100 + kind
      return;

   elseif ( nargin == 0 )

      class = magic;
      return;

   else
      error('bad number of arguments');
   end

   class = 0;
   kind = 0;

% eof
