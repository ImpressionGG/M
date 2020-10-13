function o = enable(o,arg2,types)
%
% ENABLE   Enable or disable menu item
%
%             oo = mitem(o,'Menu Item')   % create menu item
%
%             enable(oo,1)                % enable menu item
%             enable(oo,0)                % disable menu item
%
%          Enable if current object matches type list
%
%             enabled = o.is(type(o),{'weird','ball'})
%             enable(oo,enabled)
%
%          Enable if one basket object matches type list
%
%             enable(oo,basket(o),{'weird','ball'})
%
%          Copyright(c): Bluenetics 2020 
%
%          See also: CORAZON, MITEM, VISIBLE
%
   hdl = work(o,'mitem');
   if isempty(hdl)
      error('empty menu item handle!');
   end
   
   if (nargin == 2)
      condition = arg2;                   
      if (condition)
         set(hdl,'enable','on');
      else
         set(hdl,'enable','off');
      end
   elseif (nargin == 3)
      list = arg2;
      if ~iscell(types)
         error('list of types expected for arg3!');
      end
      for (i=1:length(list))
         if o.is(type(list{i}),types)
            set(hdl,'enable','on');
            return                     % one match is enough - bye!
         end
      end
      set(hdl,'enable','off');         % otherwise disable menu item
   else
      error('2 or 3 input args expected!');
   end
end