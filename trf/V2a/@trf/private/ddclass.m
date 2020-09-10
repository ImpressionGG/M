function cid = ddclass(prefix)
%
% DDCLASS   Return class ID or prefix of a DD class
%
%              cid = ddclass(prefix)
%              prefix = ddclass(cid)
%              table = ddclass
%              ddclass(NaN)
%
%           ddclass(prefix) returns an integer class ID relating to a
%           3 character string prefix which uniquely identifies a DD class.
%
%           ddclass(cid) is the converse action where an integer ID is
%           supplied to return the corresponding prefix string. A zero
%           class ID produces the string 'mat' and '???' is returned for
%           invalid DD class IDs.
%
%           A table of DD class prefixes is internally stored by the global
%           variable ddClasses which is returned by a ddclass call without
%           arguments. This table will be initialized by ddclass(NaN) and
%           is extended on each ddclass(prefix) call if prefix is not cur-
%           rently contained in the internal table.
%
%           Example:
%
%              cid = ddclass('my_') 
%
%           cid is assigned an integer class ID of the DD class specified
%           by the 3 character string 'my_'. The class relates to the func-
%           tions my_add, my_sub, my_mul, my_div, etc. which are post called
%           by the data directed functions ddadd, ddsub, ddmul, dddiv, etc.
%           if all arguments are recognized (possibly after coercing them) 
%           as instances of the 'my_' class.
%           
%           See also DD, DDCALL, DDCOERCE, DDMAGIC, DDDISP, DDADD, DDSUB,
%                    DDMUL, DDDIV
%

   global ddClasses ddCoercion;


   if ( nargin == 0 )
      cid = ddClasses;
      return
   end
      

   if ( isnan(prefix) )
      ddClasses  = [];
      ddCoercion = [];
      return;
   end

      % For integer input argument return corresponding prefix

   if ( ~isstr(prefix) & length(prefix) == 1 )
      [m,n] = size(ddClasses);
      if ( prefix == 0 )
         cid = 'mat';
      elseif ( prefix > 0 & prefix <= m )
         cid = ddClasses(prefix,:);
      else
         cid = '???';
      end
      return
   end


      % check prefix argument


   [m,n] = size(prefix);

   if ( ~isstr(prefix) | m ~= 1 | n ~= 3 )
      error('prefix (arg 1) must be a 3 character string');
   end


      % lookup prefix in table


   [m,n] = size(ddClasses);

   for (i = 1:m)
      if ( strcmp(prefix,ddClasses(i,:)) )
         cid = i;
         return;
      end
   end      

      % prefix has not been stored in table - append it!

   ddClasses = [ddClasses; prefix];

   cid = m+1;

  
      % append coercion entry


   ddCoercion = [ddCoercion; [cid cid]];

% eof
