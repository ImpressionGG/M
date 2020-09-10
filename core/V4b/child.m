function ch = child(hdl,idx)
%
% CHILD   Get child or children of a grahpics item
%
%            ch = child(hdl)       % all children
%            ch = child(hdl,2)     % 2nd child
%            ch = child(hdl,inf)   % last child
%
%
%         If no output arguments are supplied a GTREE (graphics tree)
%         call is automatically invoked after calculating the children.
%         In case of a single child a GET call is invoked before.
%
%         See also: GET, PUT, UIMENU, UICONTROL, FIGURE, AXES
%
   if ( length(hdl) > 1 ) error('arg1 must be scalar!'); end

   ch = get(hdl,'children');

   if ( nargin >= 2 )
      if ( length(idx) > 1 ) error('arg2 must be scalar!'); end
      l = length(ch);
      if ( isinf(idx) )
         ch = ch(length(ch));
      elseif ( idx > l )
         ch = [];
      else
         ch = ch(idx);
      end
   end

   if ( nargout == 0 )
      if ( length(ch) == 1 )
         get(ch);
         gtree(ch);
      else
         for (i=1:length(ch))
            gtree(ch(i));
         end
      end
   end

% eof

