function [oo,po] = mseek(o,arg)
%
% MSEEK   Seek a menu item
%
%    Seek either by a menu item path or by userdata. Second out arg is
%    setup for parent object.
%
%       o = mitem(o);                            % setup figure root
%       [oo,po] = mseek(o,{'#','Select'})        % find top label 'Select'
%       [oo,po] = mseek(o,{'Select'})            % find label 'Select'
%       [oo,po] = mseek(o,{'Select','Objects'})  % find label sequence
%
%       [oo,po] = mseek(o,userdata)              % non cell userdata
%
%       path = mseek(o)                          % get menu path
%
%    Example: assume that sub menu header is setup with 
%
%       function oo = Config(o)
%          oo = mhead(o,'Config',{},'$Config$');
%             :    :
%       end
%
%    then the following two lines can be used for menu rebuild:
%
%       [~,po] = mseek(o,'$Config$');            % seek parent of header
%       oo = Config(po);                         % rebuild menu
%
%    Note: if item not found then empty oo and po are returned!
%
%    See also: QUARK, MITEM, MHEAD
%
   gob = gluon;
   gob.profiler('mseek',1);
   mhdl = work(o,'mitem');
   
   if isempty(mhdl)
      fig = figure(o);
      if isempty(fig)
         fig = gcf(gob);
      end
      if isempty(fig)
         oo = [];
         gob.profiler('mseek',0);
         return
      end
      mhdl = fig;
   end
   
   if (nargin == 1)
      oo = MenuPath(o,mhdl);
      gob.profiler('mseek',0);
      return
   end
   
   if ~iscell(arg)
      hdl = findobj(mhdl,'userdata',arg);
      if isempty(hdl)
         oo = [];  po = [];         % cannot find
         gob.profiler('mseek',0);
         return
      end
      oo = work(o,'mitem',hdl);
   end
%
% Otherwise find along menu path
%
   if iscell(arg)
      list = arg;
      hdl = mhdl;
      
      if ~isempty(list)
         item = list{1};
         if length(item) > 0 && isequal(item(1),'#')
            hdl = figure(o);
            list(1) = [];
         end
      end

      for (i=1:length(list))
         label = list{i};
         if ~ischar(label)
            error('menu path (arg2) must be a list of strings!');
         end
         
         parent = hdl;                 % mind this handle
         gob.profiler('MseekFindobj',1);
         hdl = findobj(hdl,'label',label);
         gob.profiler('MseekFindobj',0);
         if isempty(hdl)
            oo = [];  po = [];         % cannot find
            gob.profiler('mseek',0);
            return
         end
         
         phdl = get(hdl,'parent');
         found = false;
         for (i=1:length(phdl))
            if iscell(phdl) && isequal(phdl{i},parent) || isequal(phdl(i),parent)
               found = true;
               hdl = hdl(i);
               break;
            end
         end
         
         if ~found
            oo = [];  po = [];         % cannot find
            gob.profiler('mseek',0);
            return
         end
      end

      %oo = work(o,'mitem',hdl(1));
      oo = o;
      oo.wrk.mitem = hdl(1);
   end
%
% setup parent object
%
   if (nargout > 1)
      type = get(hdl,'type');
      %if isscreen(hdl)
      if isequal(type,'root')
         parent = [];
      else
         parent = get(hdl,'parent');
      end
      po = work(oo,'mitem',parent);
   end
   gob.profiler('mseek',0);
end

%==========================================================================
% Get Menu Path
%==========================================================================

function path = MenuPath(o,hdl)        % Get Menu Path                 
   %[is,isfigure,iif] = util(o,'is','isfigure','iif');
   %[isscreen,isghandle] = util(o,'isscreen','isghandle');
   
   %if ~isghandle(hdl)
   if isempty(hdl)
      path = {};
      return
   end
   
   handles = [hdl];
   type = get(hdl,'type');
   %while ~isscreen(hdl) && ~isfigure(hdl)
   while ~isequal(type,'root') && ~isequal(type,'figure')
      hdl = get(hdl,'parent');
      type = get(hdl,'type');
      handles = [hdl handles];
   end
   
   path = {};
   for (i=1:length(handles))
      hdl = handles(i);
      type = get(hdl,'type');
      %if isscreen(hdl)
      if isequal(type,'root')
         path{end+1} = '#0';
      %elseif isfigure(hdl)
      elseif isequal(type,'figure')
         number = double(hdl);
         path{end+1} = sprintf('#%g',number);
      else
         path{end+1} = get(hdl,'label');
      end
   end
end
