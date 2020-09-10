function o = clip(dummy,o)
%
% CLIP   Put/get container object on clip boadr
%
%    Paste a container object on clipboard. The actual clipboard data is
%    represented as the list of children.
%
%       clip(carabao,o)             % put a container object to clipboard
%       o = clip(carabao)           % get a container object from clipboard
%
%    Example
%
%       paste(carabao,clip(carabao))% paste objects from clipboard
%
%    Code lines: 25
%
%    See also: CARABAO, PASTE, ADD, REMOVE
%
   bull = carabull;                        % need to access methods
   clipboard = shelf(bull,0,'clipboard');  % fetch clipboard from shelf
   if isempty(clipboard)
      clipboard = {};
   end
   
   if (nargin == 1)
      bag = pack(carabao('container'));
      bag.data = clipboard;
      o = construct(bull,bag);
   elseif (nargin == 2)
      if ~isobject(o)
         error('need an object for arg2!');
      end
      if container(o)                    % do we have a container object?
         bag = pack(o);
         list = bag.data;
      else
         list = {pack(o)};
      end
      shelf(bull,0,'clipboard',list);  % store clipboard back to shelf
   else
      error('1 or 2 input args expected!');
   end
end
