function oo = note(o,src,vol)
%
% NOTE  Create a note atom: note(o,src,vol) where src is the source string
%       of a note and vol denotes its volume creates  a note atom.
%
%          oo = note(o,'c')            % C4
%          oo = note(o,'c#')           % C#4
%          oo = note(o,'c°')           % Cb4
%
%       With duration
%
%          oo = note(o,'a**')          % A4, 1/1 beat
%          oo = note(o,'a*.')          % A4, 3/4 beat
%          oo = note(o,'a*')           % A4, 1/2 beat
%          oo = note(o,'a')            % A4, 1/4 beat
%          oo = note(o,'a/')           % A4, 1/8 beat
%          oo = note(o,'a//')          % A4, 1/16 beat
%          oo = note(o,'a///')         % A4, 1/32 beat
%
%       Loudness
%
%          oo = note(g)                % G4, 1/4 beat, volume 100
%          oo = note(g,100)            % G4, 1/4 beat, volume 100
%          oo = note(g,55)             % G4, 1/4 beat, volume 55
%
%       Pause
%          oo = note(o,';**')          % 1/1 beat pause
%          oo = note(o,';*.')          % 3/4 beat pause
%          oo = note(o,';*')           % 1/2 beat pause
%          oo = note(o,';')            % 1/4 beat pause
%          oo = note(o,';/')           % 1/8 beat pause
%          oo = note(o,';//')          % 1/16 beat pause
%
%       Example
%
%          o = new(midi,'Piano');      % create band object with 1x piano
%          c = note(o,'c');
%          e = note(o,'e');
%          g = note(o,'g');
%
%          sound(o,c)                  % play sound of note c
%          sound(o,e)                  % play sound of note e
%          sound(o,g)                  % play sound of note g
%
%          sound(o,{c e g})            % play sound of sequence c,e,g
%          sound(o,{c;e,g})            % play sound of chord ceg
%
%       See also: MIDI, SOUND
%
   oo = Compile(o,src);
   
   if (nargin >= 3)
      oo.data.velocity = vol;
   end
   
   oo.par.source = src;
end

%==========================================================================
% Generate Note
%==========================================================================

function oo = Note(o,pitch,duration,velocity)
%
% NOTE  Generate a MIDI line representing a note
%
%       Description of MIDI columns (beat unit is ticks per quarter note)
%
%          1: onset (beats)
%          2: duration (beats)
%          3: MIDI channel
%          4: MIDI pitch (pitch = key+20, e.g. C4 key = 40, C4 pitch = 60)
%          5: velocity (how fast is key of note pressed, i.e loudness)
%          6: onset (seconds)
%          7: duration (seconds)
%
%       MIDI file example (Laksin)
%
%          0.0  0.9000   1    64  82    0.0000  0.5510
%          1.0  0.9000   1    71  89    0.6122  0.5510
%          2.0  0.4500   1    71  82    1.2245  0.2755
%          2.5  0.4500   1    69  70    1.5306  0.2755
%          3.0  0.4528   1    67  72    1.8367  0.2772
%          3.5  0.4528   1    66  72    2.1429  0.2772
%          4.0  0.9000   1    64  70    2.4490  0.5510
%          5.0  0.9000   1    66  79    3.0612  0.5510
%          6.0  0.9000   1    67  85    3.6735  0.5510
%          7.0  1.7500   1    66  72    4.2857  1.0714 
% 
   if (nargin < 4)
      duration = 1;
   end
   if (nargin < 5)
      velocity = 100;
   end
   
   fac = 1;
   velocity = 100;
   
      % create  note object
      
   oo = midi('note');
   
   oo.data.time = 0;
   oo.data.duration = duration;
   oo.data.channel = 0;
   oo.data.pitch = pitch;
   oo.data.velocity = velocity;   

   oo.data.tsec = oo.data.time*fac;
   oo.data.dsec = oo.data.duration*fac;
end

%==========================================================================
% Song Compilation
%==========================================================================

function [c,source] = Next(source)
%
% NEXT Get next character,either WITH or WITHOUT eating
%
%         c = Next(source)              % without eating
%         [c,source] = Next(source)      % with eating
%
   if (nargout <= 1)                   % without eating
      if isempty(source)
         c = '?';
      else
         c = source(1);
      end
   else
      c = source(1);
      source(1) = [];
   end
end

function [source,kind,value,duration] = Token(source)
   duration = 1;
   
   [c,source] = Next(source);

      % space detection results in a 'space' token
      
   if (c == ' ')
      while (Next(source) == ' ')
         [source,c] = Next(source);
      end
      duration = 0;
      kind = 'space';
      value = [];
      duration = 0;
      return
   end
   
      % some other token
      
   kind = 'note';
   switch c
      case 'c'
         value.key = 40;
      case 'd'
         value.key = 42;
      case 'e'
         value.key = 44;
      case 'f'
         value.key = 45;
      case 'g'
         value.key = 47;
      case 'a'
         value.key = 49;
      case 'b'
         value.key = 51;
      case ';'
         value.key = 0;
      otherwise
         fprintf('parsing at: %s\n',[c,source]);
         error('syntax error');
   end
   
      % any post operators?
      
   while (1)
      c = Next(source);
      switch c
         case '*'
            [c,source] = Next(source);
            duration = duration*2;
         case '/'
            [c,source] = Next(source);
            duration = duration/2;
         case '.'
            [c,source] = Next(source);
            duration = duration*1.5;
         case '#'
            [c,source] = Next(source);
            value.key = value.key+1;
         case '°'
            [c,source] = Next(source);
            value.key = value.key-1;
         case '+'
            [c,source] = Next(source);
            value.key = value.key+12;
         case '-'
            [c,source] = Next(source);
            value.key = value.key-12;
         otherwise
            return
      end
   end
end

function oo = Compile(o,source)   
   if isempty(source)
      error('empty source string');
   end
   
   [source,kind,value,duration] = Token(source); 
   
   if ~isequal(kind,'note')
      error('syntax error');
   end
   
   pitch = value.key + 20;
   velocity = 100;
   oo = Note(o,pitch,duration,velocity);

            
   if ~isempty(source)
      error('syntax error');
   end
end