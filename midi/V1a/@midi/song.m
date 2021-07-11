function oo  = song(o,list,title)
%
% SONG  Create a song object from music list
%
%          s = song(o,'c d e f g* g*','Alle Meine Entchen')
%
%          s = song(o,music('c d e f g* g*'))
%          s = song(o,music('c d e f g* g*'),'Alle Meine Entchen')
%           
%          Example
%             o = new(midi,'Piano');
%             s = song(o,'c d e f g* g*','Alle Meine Entchen');
%             sound(o,s);
%
%       See also: MIDI
%
   if ischar(list)
      text = list;
      list = music(o,text);
   end

   oo = midi('song');
   
      % check list
      
   for (i=1:length(list))
      item = list{i};
      if ~(isa(item,'midi') && type(item,{'note','chord'}))
         error('music list must only contain notes or chords');
      end
   end
   
   oo.data.list = list;
   if (nargin >= 3) && ~isempty(title)
      oo.par.title = title;
   end
end