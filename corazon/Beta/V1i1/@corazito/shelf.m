function value = shelf(o,fig,tag,value)
%
% SHELF   A shelf to store class specific userdata of figures or axes or
%         the screen
%
%    Note that the figure/axis handle has to be provide explicitely (this
%    is by intention). The figure/axis handle can denote a figure (fig = 1,
%    2,3,...) which addresses a figure's shelf, an axis handle adressing
%    the axis' shelf or the screen (fig = 0) which means
%    the global shelf.
%
%       shelf(o,fig,tag,value)    % store value in figure shelf @ tag
%       value = shelf(o,fig,tag)  % recall value from figure shelf @ tag
%
%       shelf(o,gcf,'object',o)   % store o in cur. fig. shelf @ 'object'
%       o = shelf(o,gcf,'object') % recall value from cur. fig. shelf @ tag
%
%       shelf(o,fig,'',bag)       % replace whole shelf with bag
%       bag = shelf(o,fig)        % recall whole shelf storage
%       shelf(o);                 % display whole shelf
%
%       shelf(o,0,'mag',magic(5)) % store magic(5) in screen's shelf
%
%       shelf(o,gca,'closeup',0)  % store 0 under 'closeup' in axis shelf
%       f = shelf(o,gca,'closeup')% retrieve 'closeup' from axis shelf
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO
%
   if (nargin == 1)                    % return/display whole shelf
      val = shelf(o,gcf,'');
      if (nargout == 0)
         fprintf('Shelf (%s)\n',class(o));
         disp(val);
      else
         value = val;                  % copy to output arg
      end
      return
   end
   
   userdata = get(fig,'userdata');
   if ~isempty(userdata) && ~isstruct(userdata)
      error('cannot proceed since userdata is no structure!');
   end
%
% Two input args or empty tag
% a) shelf(o,fig,'',bag)               % replace whole shelf with bag
% b) bag = shelf(o,fig)                % recall whole shelf storage
% c) bag = shelf(o,fig,'')             % recall whole shelf storage
%
   while (nargin <= 2) || isempty(tag)
      shelftag = ['userdata'];         % to store full bag of values
      if (nargin <= 3)                 % recall a value
         value = userdata;
      elseif isstruct(value) || isempty(value)
         set(fig,'userdata',value);
      else
         error('bad calling syntax!');
      end
      return
   end
%
% Non empty tag
% a) shelf(o,fig,tag,value) % store value in figure shelf @ tag
% b) value = shelf(o,fig,tag) % recall value from figure shelf @ tag
% c) shelf(o,gcf,'object',o) % store o in cur. fig. shelf @ 'object'
% d) o = shelf(o,gcf,'object') % recall value from cur. fig. shelf @ tag
%   
   if (nargin == 3)                    % recall a value
      if isempty(find(tag=='.'))
         if isfield(userdata,tag)
            value = userdata.(tag);
         else
            value = [];
         end
      else
         value = eval(['userdata.',tag],'[]');
      end
   elseif (nargin == 4)
      if isempty(find(tag=='.'))
         userdata.(tag) = value;
      else
         eval(['userdata.',tag,' = value;']);
      end
      set(fig,'userdata',userdata);
   else
      error('bad calling syntax!');
   end
end
