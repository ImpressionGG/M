function txt = display(o)              % Display MIDI Object        
%
% DISPLAY  Display MIDI object
%
%          Copyright(c): Hugo von Tirol 2021
%
%          See also: MIDI
%
   switch o.type
      case '-note'
         src = get(o,'source');
         if isempty(src)
            src = sprintf('%s@%s',o.data.pitch,o.data.duration);
         end
         fprintf('<%s>\n',src);
      
      otherwise
         display(corazon,o);           % display in corazon style
   end
end
