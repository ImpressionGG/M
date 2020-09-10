function obj = data(obj,d,value)
% 
% DATA   Get or set data of a CORE object
%      
%             obj = core                     % create a CORE object
%             dat = data(obj)                % get whole data structure
%             obj = data(obj,dat)            % set whole data structure
%
%             value = data(obj,'tag')        % get data of field 'tag'
%             obj = data(obj,'tag',value)    % set data of field 'tag'
%
%        See also: CORE SET GET TYPE INFO DISPLAY

   if (nargin == 1)
      obj = obj.data;      
   elseif (nargin == 2)
      if (isstr(d))          % string argument 2? 
         eval(['obj = obj.data.',d,';'],'obj = [];');
      else
         obj.data = d;
      end
   elseif (nargin == 3)
      eval(['obj.data.',d,'=value;']);
   else
      error('shell::data(): 1,2 or 3 args expected!');
   end
   return
end   
