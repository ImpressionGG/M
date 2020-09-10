function value = get(obj,parname)
% 
% GET      Get user defined parameter of a SMART object
%      
%             obj = smart                        % create SMART object
%             value = get(obj,parname)           % get parameter value
%             list = get(obj)                    % get parameter list
%
%          See also: SMART SET
   
   if (nargin == 1)  % return parameter list
       value = obj.parameter;
   elseif (nargin == 2) % get user parameter value
      eval(['value = obj.parameter.',parname,';'],'value = [];');
   else
      error('bad number of args!');
   end
   return   
   
% eof
