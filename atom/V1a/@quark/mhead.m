function oo = mhead(o,path,callback,userdata,varargin)
%
% MHEAD   Provide a menu header item
%
%    First the menu item is seeked. When found all its children are
%    deleted.
%
%       oo = mhead(o,'Objects');
%       oo = mhead(o,{'Select','Objects'});
%
%       oo = mhead(o,label,callback,userdata);
%
%    Example
%
%       function oo = Objects(o)
%          oo = mhead(o,'Objects','','select.current');
%       end
%
%       function oo = RefreshhObjects(o)
%          [~,po] = mseek(mitem(o),'select.current');
%          oo = Objects(po);
%       end
%
%    See also: QUARK, MITEM, MSEEK
%
   gluon.profiler('mhead',1);
   if isempty(work(o,'mitem'))
      o = work(o,'mitem',figure(o));   % init mitem handle
   end
   
   if isempty(path)
      error('label/path (arg2) must not be empty!');
   end
%
% first seek path and extract label
%
   if ischar(path)
      oo = mseek(o,{path});
      label = path;
   else
      oo = mseek(o,path);
      label = path{end};
   end
   
   if isempty(oo)                      % does not exist
      if (nargin == 2)
         oo = mitem(o,label);
      elseif (nargin == 3)
         oo = mitem(o,label,callback);
      elseif (nargin == 4)
         oo = mitem(o,label,callback,userdata);
      else
         oo = mitem(o,label,callback,userdata,varargin);
      end
   else
      hdl = work(oo,'mitem');
      kids = get(hdl,'children');
      delete(kids);                    % delete all kids
      
      for (i=1:2:length(varargin)-1)
         tag = varargin{i};
         value = varargin{i+1};
         set(hdl,tag,value);
      end
   end
   gluon.profiler('mhead',0);
end      
