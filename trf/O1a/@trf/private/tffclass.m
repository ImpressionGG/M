function class = tffclass
%
% TFFCLASS  Return class index for transfer function class
%
%              class = tffclass
%
%           See also: TFFNEW DDCLASS
%           
%
   global tffClass

   if ( isempty(tffClass) )
      tffClass = ddclass('tff');
      ddcoerce([0 tffClass]);        % setup coercion
   end

   class = tffClass;

end
