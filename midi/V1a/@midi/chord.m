function oo = chord(o,list)
%
% CHORD  Create a MIDI chord object
%
%           oo = chord(o,column)
%
%        Examples
%
%           c = note(o,'c');  e = note(o,'e');  g = note(o,'g');
%
%           o = new(midi,'Piano');
%           oo = chord(o,{c;e;g});
%           sound(o,oo);
%
%        See also: MIDI, NOTE, SOUND
%
   if (~iscell(list) || size(list,1) <= 1)
      error('column expected for arg2 with 2 or more notes');
   end
   
   src = '';
   
   for (i=1:length(list))
      item = list{i};
      if ~isa(item,'midi') || ~type(item,{'note'})
         error('column of notes expected for arg2');
      end
      src = [src,item.par.source];
      duration(1,i) = item.data.duration;
      pitch(i) = item.data.pitch;
   end
   
   oo = midi('chord');
   oo.par.source = src;
   oo.par.title = ['<chord ',src,'>'];
   oo.data.chord = list;
   oo.data.time = 0;
   oo.data.pitch = pitch;
   oo.data.duration = duration;
   oo.data.channel = 0*duration;
end