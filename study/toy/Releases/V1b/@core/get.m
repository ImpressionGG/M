function value = get(obj,parname)
% 
% GET      Get user defined parameter of a CORE object
%      
%             obj = core(typ)                 % construct a CORE object
%             value = get(obj,parameter)      % get user parameter value
%             list = get(obj)                 % get parameter list
%
%          See also: CORE SET

   
   if (nargin == 1)  % return parameter list
       value = obj.parameter;
   elseif (nargin == 2) % get user parameter value
      eval(['value = obj.parameter.',parname,';'],'value = [];');
   else
      error('bad number of args!');
   end
   return   
end
