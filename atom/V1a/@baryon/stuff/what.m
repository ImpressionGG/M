function oo = what(o,title,varargin)
%
% WHAT   What we see! Setup or display plot information. 
%
%    The what information is stored in the 'shell.what' settings
%
%       what(o,title,comment);        % setup 'what info'
%       what(o,title,tx1,tx2,...);    % setup 'what info'
%       what(o,o);                    % setup 'what info' using object info
%       what(o,[]);                   % reset 'what info'
%
%       what(o);                      % pop up plot info
%       pair = what(o);               % fetch plot info
%
%       o = what(o,title,texts);      % store in control options
%       o = what(o,title,tx1,...);    % store in control options
%
%    Example:
%
%       what(o,'UC Footprint',{'green: pF1,pF2','blue: rU'});
%       what(o,'UC Footprint','green: pF1,pF2','blue: rU');
%
%    See also: CARABAO, MESSAGE
%
   is = @o.is;                         % need some utility function
%
% one input arg
% a) what(o) % pop up plot info
% b) pair = what(o) % fetch plot info
%
   while (nargin == 1)                 % process 1 input arg           
      oo = [];                         % empty by default
      pair = control(o,'what');
      if (nargout >= 1)
         oo = pair;
         return
      end
      
      if isempty(pair)
         message(o,'No ''what info'' available!','(for current context)');
      else
         message(o,pair{1},pair{2});
      end
      return
   end
%
% Two input args and empty arg2 or arg2 is an object
% a) what(o,o) % setup 'what info' using object info
% b) what(o,[]) % reset plot info
%
   while (nargin == 2 && (isobject(title) || is(title,[])))
      if is(title,[])
         pair = {'',{}};
      else
         oo = title;                    % title is an object
         pair{1} = get(oo,{'title',''});
         pair{2} = get(oo,{'comment',{}});
      end
      
      if (nargout > 0)
         oo = control(o,'what',pair);   % return 'what info' in options
      else
         control(o,'what',pair);        % store in control settings
      end
      return
   end
%
% More than 1 input arg
%   
   while (nargin > 1)                  % process more than 1 input arg 
      pair = {'',''};
      if ~isempty(title)
         pair{1} = title;
         if isempty(varargin)
            pair{2} = '';
         elseif iscell(varargin{1})
            if ~(ischar(varargin{1}) || iscell(varargin{1}))
               error('comment must be a string or list!');
            end
            pair{2} = varargin{1};
         else
            for (i=1:length(varargin))
               if ~ischar(varargin{i})
                  error('all comments in list must be a string!');
               end
            end
            pair{2} = varargin;
         end
      end
      
      if (nargout > 0)
         oo = control(o,'what',pair);   % return plot info in options
      else
         control(o,'what',pair);        % store in control settings
      end
      return
   end
%
% never run beyond this point!
%
   assert(0);  
end   
   