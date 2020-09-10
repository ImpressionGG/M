function oo = edit(o,idx)              % Edit Object Parameters        
%
% EDIT   Edit object parameters
%
%           oo = edit(o);              % edit provided object directly
%           edit(o);                   % edit current object
%           edit(o,idx);               % edit object with index idx
%
%        The edit dialog is constructed on base of the edit property.
%        Example:
%
%           list = {{@new 'PT1'},...
%                   {'V','Gain'},{'T','Time Constant'}}
%           o = set(o,'edit',list);
%
%        if an update callback is provided (get(oo,'update')) then the 
%        update callback will be executed after confirmed exit of the
%        edit mode.
%
%        See also: CARABAO, UPDATE
%
   if (nargin == 1) && (nargout > 0)
      provided = true;                 % have to edit provided object
   else
      provided = false;                % have to edit indexed or current 
   end
   
      % if object to be edited is not provided we have to refresh the
      % object by pulling from shell and to get to the right index
      
   if provided
      oo = o;                          % object to be edited
   else
      o = pull(o);                     % refresh object
      if (nargin == 1)
         [oo,idx] = current(o);        % edit current object
      end

      n = data(o,inf);
      if (idx < 0 || idx > n)
         message(o,'Cannot edit object properties!','Index out of range!');
         oo = o;
         return
      end
   
         % fetch indexed object
   
      if (idx == 0)
         oo = o;
      else
         oo = data(o,idx);
      end
   end
   
      % now oo holds the object which we have to edit and we can start
      % the actual editing job by preparing the edit dialog
      
   list = get(oo,{'edit',{}});
   if isempty(list)
      oo = menu(oo,'Property');        % edit object property
   else
      list = [{{'Title','title'}},list];
      oo = set(oo,'title',get(oo,{'title',''})); 
      oo = Edit(oo,list);
   end

      % on case of dialog exit with CANCEL we have to ignore further
      % processing and return
      
   if isempty(oo)
      return
   end

         % the whole editing job has been completed now. If the object has
         % been provided via input arg we are done.
         % otherwise continue   

   if (provided)
      return                           % all done - good bye!
   end
   
      % otherwise we have to put object back into shell.
      % we finally invoke also a refresh call.
      
   if (idx == 0)
      o = oo;
   else
      o.data{idx} = oo;
   end
   
   push(o);
   event(o,'select');
   refresh(o);
end

function oo = Edit(oo,list)
   prompts = {};  values = {};
   for (i=1:length(list))
      pair = list{i};
      prompts{end+1} = pair{1};
      
      tag = pair{2};
      value = get(oo,tag);
      if isa(value,'double')
         value = sprintf('%g',value);
      elseif ischar(value)
         'ok!';
      else
         value = '';
      end
      values{end+1} = value;
   end
   
   %caption = get(oo,{'title','Properties'});
   caption = 'Edit Properties';
   dims = ones(length(values),1)*[1 50];  % dims(2,1) = 3;
   
   values = inputdlg(prompts,caption,dims,values);   
   if isempty(values)
      oo = [];
      return                           % user pressed CANCEL
   end
   
   for (i=1:length(list))
      pair = list{i};
      tag = pair{2};
      value = get(oo,tag);
      if isa(value,'double')
         str = values{i};
         value = sscanf(str,'%f');
         oo = set(oo,tag,value);
      elseif ischar(value)
         oo = set(oo,tag,values{i});
      else
         'ignore!';
      end
   end
   
      % now update the object
      
   cblist = get(oo,'update');
   if ~isempty(cblist)
      [oo,gamma] = call(oo,cblist);    % get call parameters
      oo = gamma(oo);                  % actual callback
   end
end
