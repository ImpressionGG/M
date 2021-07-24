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
