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
%           song = chord(o,'C')
%           song = chord(o,'G')
%           song = chord(o,'F')
%
%        Chord sequence  - write a song
%
%           song = chord(o,[1 1 1 -3 -3 -3 -3 5 5 5])
%
%        Relative chords
%
%           o = set(midi,'scale','C');         % C major scale
%
%           song = chord(o,+1)                 % C major scale: 'ceg'
%           song = chord(o,-2)                 % D minor scale: 'dfa'
%           song = chord(o,-3)                 % E minor scale: 'egb'
%           song = chord(o,+4)                 % F major scale: 'fac'
%           song = chord(o,+5)                 % G major scale: 'gbc'
%           song = chord(o,-6)                 % A minor scale: 'ace'
%           song = chord(o,-7)                 % B minor scale: 'bdf'
%
%        See also: MIDI, NOTE, SOUND
%

      % if 2nd arg is a number then return chord by number (positive
      % numbers denote majors and negative numers minors

   if isa(list,'double')
      if (length(list) == 1)
         oo = Chord(o,list);
      else
         chords = {};
         for (i=1:length(list))
            chords{i} = Chord(o,list(i));
         end
         oo = song(o,chords);
      end
      return
   end

      % otherwise we can expect a column list
      
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

%==========================================================================
% Chord by Number
%==========================================================================

function oo = Chord(o,number)
   tones = {'c','d°','d','e°','e','f','g°','g','a°','a','b°','b',...
            'c','c#','d','d#','e','f','f#','g','g#','a','a#','b','c'};
   
   switch abs(number)
      case 1                           % C
         title = 'C';
         maj = {'c','e','g'};
         min = {'c','e°','g'};
      case 2                           % D
         title = 'D';
         maj = {'d','f#','a'};
         min = {'d','f','a'};
      case 3                           % E
         title = 'E';
         maj = {'b-','e','g#'};
         min = {'b-','e','g'};
      case 4                           % F
         title = 'F';
         maj = {'f','a','c'};
         min = {'f','a°','c'};
      case 5                           % G
         title = 'G';
         maj = {'g','b','d'};
         min = {'g','b°','d'};
      case 6                           % A
         title = 'A';
         maj = {'a','c#','e'};
         min = {'a','c','e'};
      case 7                           % B
         title = 'B';
         maj = {'b','d#','f'};
         min = {'b','d','f'};
      otherwise
         error('abs(arg2) must be in range 1..7');
   end
   
   src = '';
   if (number > 0)
      for (i=1:3)
         list{i,1} = note(o,maj{i});
         src = [src,maj{i}];
      end
   else
      for (i=1:3)
         list{i,1} = note(o,min{i});
         src = [src,min{i}];
      end
   end
   
   oo = chord(o,list);
   oo.par.source = src;
   oo.par.title = [title,o.iif(number<0,'m','')];
end
