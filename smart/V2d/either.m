function result = either(value,default)
%
% EITHER   Convenience function: return either nonempty value or provide
%          default value.
%
%             result = either(value,default)
%
%          A typical example for either() is to retrieve an option value
%          or a shell setting, and provide a default value for the case
%          that the option or SHELL setting is empty.
%
%          Examples:
%
%             result = either(8,3);   % result = 8
%             result = either([],3);  % result = 3
%
%             value = either(setting('bullets'),0);
%             value = either(option(obj,'bullets'),0);
%
%          See also: SMART OPTION SETTING
%
   if isempty(value)
      result = default;
   else
      result = value;
   end
   return
   
%eof   