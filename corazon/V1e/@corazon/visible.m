function visible(o,arg2,types)
%
% VISIBLE  Set menu item visible or invisible
%
%             oo = mitem(o,'Menu Item')   % create menu item
%
%             visible(oo,1)               % set menu item visible
%             visible(oo,0)               % set menu item invisible
%
%          Enable visibility if current object matches type list
%
%             visual = o.is(type(o),{'weird','ball'})
%             visible(oo,visual)
%
%          Enable visibility if one basket object matches type list
%
%             visible(oo,basket(o),{'weird','ball'})
%
%          Copyright(c): Bluenetics 2020 
%
%          See also: CORAZON, MITEM, ENABLE
%
   hdl = work(o,'mitem');
   if isempty(hdl)
      error('empty menu item handle!');
   end
   
   if (nargin == 2)
      condition = arg2;                   
      if (condition)
         set(hdl,'visible','on');
      else
         set(hdl,'visible','off');
      end
   elseif (nargin == 3)
      list = arg2;
      if ~iscell(types)
         error('list of types expected for arg3!');
      end
      for (i=1:length(list))
         if o.is(type(list{i}),types)
            set(hdl,'visible','on');
            return                     % one match is enough - bye!
         end
      end
      set(hdl,'visible','off');        % otherwise disable menu item
   else
      error('2 or 3 input args expected!');
   end
end