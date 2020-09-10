function paste(o,ilist,refreshing)     % Paste Object(s) into Shell    
%
% PASTE   Paste an object into current shell
%
%    Overloaded CARAMEL method to paste a Carabao object or a list of
%    Carabao objects into current shell with the addition that package
%    parameter is automatically set if current object is a package.
%
%    In addition pasted object does not become current one, if pasting
%    into a package.
%
%       paste(o)                       % short form
%
%       paste(o,{o1,o2,...})           % paste a list of objects
%       paste(o,{o1,o2,...},false)     % paste objects without refreshing
%
%    See also: CARAMEL
%
   if (nargin == 1)
      oo = pull(o);
      co = cast(oo,'caramel');
      paste(co,{o});
      return
   end
   
   if (nargin < 3)
      refreshing = true;
   end
   
   co = current(o);                    % get current object
   typ = type(co);
   if o.is(typ,'pkg')
      package = get(co,'package');
      [oo,idx] = current(o);
   else
      package = '';
      idx = NaN;
   end
   
   if (nargin >= 2)
      for (i=1:length(ilist))
         oo = ilist{i};
         if ~o.is(get(oo,'kind'),'pkg')
            oo = set(oo,'package',package);
            ilist{i} = oo;
         else
            idx = NaN;                 % in case of package update current 
         end
         
         signal(caramel,{oo});         % conditional signal setting
      end
      
      co = cast(o,'carabao');
      paste(co,ilist,false);           % paste without refresh
      if ~isnan(idx)
         current(o,idx);
      end
      
%     for (i=1:length(ilist))
%        oo = ilist{i};
%        ocfg = config(type(o,oo.type));         
%        oocfg = config(oo);
%        if isempty(ocfg) && ~isempty(oocfg)
%           config(o,oo);
%           if (i == length(ilist))    % if last element
%              event(o,'signal');
%           end
%        end
%     end
   else
      error('2 or 3 input args expected!');
   end
   
   if (refreshing)
      if ~isempty(ilist)
         oo = ilist{end};              % last pasted object
         typ = control(o,'type');
         if ~isequal(typ,type(oo))
            refresh(o,{@menu 'About'});
         end
      end
      refresh(o);                      % refresh the screen
   end
end

