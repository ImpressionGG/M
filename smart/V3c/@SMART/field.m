function value = field(obj,name)
% 
% FIELD   Get object field (adressed by fieldname)
%      
%             obj = smart                   % create SMART object
%             fmt = field(obj,'format')     % get format field
%
%          See also SMART FIELDS

%    expr = ['obj.',name,';'];
%    value = eval(expr);
   value = obj.(name);

% eof
