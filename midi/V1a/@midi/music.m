function oo = music(o,source)
%
% MUSIC   Create MIDI music file from music source text
%
%           oo = music(midi,'c g g f e d c d e d');
%
%        Syntax:
%           a              1/4 beat a note
%           a*             1/2 beat a note
%           a**            1/1 beat a note
%           a/             1/8 beat a note
%           a//            1/16 beat a note
%           a///           1/32 beat a note
%           e°             1/4 beat ess note
%           c#             1/4 beat C# note
%
%           []             C major scale
%           [#]            G major scale
%           [##]           D major scale
%           [°]            F major scale
%           [°°]           Bb major scale
%
%           C              C major chord
%           G              G major chord
%
%           I              1st major chord of current scale
%           ii             2nd minor chord of current scale
%           IV**           1/1 beat 4th major chord
%
%        See also: MIDI, BAND, SOUND
%
   oo = Compile(o,source)
end

%==========================================================================
% Generate Note
%==========================================================================

function note = Note(o,time,pitch,duration,velocity)
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
   note = [time,duration,1, pitch,100,  time*fac,duration*fac];
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
   oo = midi('midi');
   oo.par.source = source;
   
   time = 0;
   nmat = [];
   dt = 0;
   
   while ~isempty(source)
      [source,kind,value,duration] = Token(source); 
      switch (kind)
         case 'note'
            pitch = value.key + 20;
            velocity = 100;
            nmat(end+1,:) = Note(o,time,pitch,duration,velocity);
            dt = max(dt,duration);

         case 'space'
            time = time + dt;
            dt = 0;
      end
   end
   
      % complete 'midi'  typed object
      
   oo.data.nmat = nmat;
end