function oo = mitem(o,label,clist,userdata,varargin) % Create Menu Item              
%
% MITEM   Add menu item
%
%    A uimenu item will be added with an implicite callback to 'call'.
%    The handle of the new created menu item is stored in the working
%    property work(o,'mitem').
%
%    Callbacks are always passed as calling list with the first list item
%    being a string (function name) or a function handle.
%
%       mitem(o)                       % display menu item info
%       o = mitem(o);                  % set top level handle
%       oo = mitem(o,'File');
%       ooo = mitem(oo,'Open',{@Open});
%       ooo = mitem(oo,'Save',{@Save},userdata);
%
%    Get/set graphics handle
%
%       hdl = work(o,'mitem')          % get graphics handle
%       o = work(o,'mitem',hdl)        % set graphics handle
%
%    See also: QUARK
% 
   persistent separator
   tag = 'mitem';                      % tag for mitem handle
   h = work(o,tag);
%
% One input arg
% a) hdl = mitem(o) % get handle
%
   while (nargin == 1)
      if isempty(h)
         h = gcf;
      end
      oo = work(o,tag,h);
      return
   end
%
% Intermezzo with separator
%
   while isequal(label,'-')              % if separator label
      separator = 1;
      oo = [];
      return
   end
%
% Two input args and arg2 is a string
% a) oo = mitem(o,'File');
%   
   while (nargin == 2)   
      hh = uimenu(h,'label',label);
      oo = work(o,tag,hh);
      
      if ~isempty(separator)
         set(hh,'separator','on');
         separator = [];
      end     
      return      
   end
%
% Three input args
% a) ooo = mitem(oo,'Load ...',{@Load})
% b) oooo = mitem(ooo,'Red',{@SetColor 'r'})
% c) oooo = mitem(ooo,'Blue',{@SetColor 'b'})
% d) oooo = mitem(ooo,'Color','','view.color')
%   
   while (nargin >= 3)
      if ~(iscell(clist) || ischar(clist)) && (nargin == 3)
         error('calling list (arg3) must be a string or list!');
      end
      
      hh = uimenu(h,'label',label);    % create uimenu item
      if ischar(clist)
         set(hh,'callback',clist);
      elseif ~isempty(clist)
         callback = call(o,class(o),clist);  % construct callback
         set(hh,'callback',callback);
      end
      
      if (nargin >= 4)
         set(hh,'userdata',userdata);
      end
      
      if ~isempty(separator)
         set(hh,'separator','on');
         separator = [];
      end
      
      for (i=1:2:length(varargin)-1)
         set(hh,varargin{i},varargin{i+1});  % set other properties
      end
      
      oo = work(o,tag,hh);
      return
   end
%
% Any move beyond that point indicates a syntax error
%
   error('1,2 or 3 input args expected!')
%
% handle separator
%
end
