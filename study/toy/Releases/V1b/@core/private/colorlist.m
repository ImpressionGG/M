function clist = colorlist(arg1,arg2)
%
% COLORLIST  Get color list for sequential plots
%
%               clist = colorlist           % default length
%               clist = colorlist(n)        % length n (cyclical)
%               clist = colorlist([],n)     % same as colorlist(n)
%               clist = colorlist(clist,n)  % length n (cyclical)
%               clist = colorlist(obj,n)    % based on object parameters
%
   if (nargin == 0)
      clist = { 
             'b'
             'g'
             'r'
             'c'
             'm'
             'y'
             'k'
             };
      return
   elseif (nargin == 1)  % clist = colorlist(n)
      n = arg1;
      clist = colorlist(colorlist,n); 
      return
   elseif (nargin == 2)  % clist = colorlist(clist,n)
      base = arg1;                            % base list
      n = arg2;                               % required length
      
         % in case of arg1 is a SMART object we fetch base color
         % list from the object parameters
         
      if (isobject(arg1)) 
         obj = arg1;                          % SMART object as arg 1
         base = eval('get(obj,''color'')','[]');
         if (isempty(base))
            base = eval('option(obj,''color'')','[]');
         end
         if isstr(base)
            base = {base};                    % always has to be a list!
         end
         if (~iscell(base))
            base = [];                        % empty if cannot be used!
         end
      end
      
         % if base is empty we go back to the default
         
      if (isempty(base))
         base = colorlist;
      end
      
         % now cyclically extend color list until we have n list items
         
      clist = [];
      for (i=1:n)
         clist{i} = base{1+rem(i-1,length(base))};  % extend list
      end
      return
   else
      error('smart::colorlist(): < 3 args expected!');
   end
      
%eof   