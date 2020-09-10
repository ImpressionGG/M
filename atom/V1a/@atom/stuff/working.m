function oo = working(o,title,varargin)
%
% WORKING Set object as working object. Change menus properly.
%         Optionally title and comment can be set
%
%            working(o)                % set o as working object
%            o = working(o,title)      % set also title of working object
%            o = working(o,tit,comment)% set also title of working object
%            o = working(o,tit,{txt1,..,txtn})
%            o = working(o,tit,txt1,..,txtn)
%
   if (nargin >= 2)
      o = set(o,'title',title);
   end
   if (nargin >= 3) && length(varargin == 1)
      comment = varargin;
      if iscell(varargin{1})
         comment = varargin{1};
      end
      for (i=1:length(comment))
         if ~ischar(comment{i})
            error('all comments must be character strings!');
         end
      end
      o = set(o,'comment',comment);
   end
   
   oo = Working(o);
end

%==========================================================================
% Work Horse
%==========================================================================
      
function oo = Working(o)
   oo = o;                             % rename working object
   o = pull(oo);                       % pull shell object
   workidx = control(o,{'working',0}); % working index
   if (workidx < 1 || workidx > length(o.data))
      workidx = length(o.data) + 1;
      control(o,'working',workidx);
   end
   o.data{workidx} = oo;
   push(o);
   
   [~,idx] = current(o);
   if (idx ~= workidx)
      current(o,workidx);
   end
   active(o,oo);                       % make sure oo.type is active
   event(o,'Select');                  % update Select menu
end
