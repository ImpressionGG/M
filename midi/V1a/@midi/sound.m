function sound(o,keys,duration,channel)
%
% SOUND Play sound on a specific instrument based on an audio typed
%       MIDI object. First argument must be a 'band'  typed object.
%
%          o = band(midi,{'Steinway Grand Piano'})
%          sound(o,oo)                 % play a MIDI object
%
%       Short form
%
%          sound(oo)                   % default band and pitch
%
%       Play sound based on particular parameters
%
%          sound(oo,keys,duration,channels)
%
%       In case of oo is a midi object
%
%          o = band(midi,{'Steinway Grand Piano'});
%          oo = new(o,'Laksin');
%          sound(o,oo)
%
%       Examples
%
%          o = new(midi,'Piano')
%          sound(o,note(o,g))
%          sound(o,music(o,'ceg'))
%
%          a = note(o,'a');
%          c = note(o,'c');
%          e = note(o,'e');
%          g = note(o,'g');
%
%          C = {c;e;g}                 % C major chord
%          Am = {a;c;e}                % A minor chord
%
%          sound(o,c)
%          sound(o,{c e g});           % play sequence
%          sound(o,{c;e;g});           % play chord
%
%          sound(o,{C,Am,C})
%
%          sound(o,{2,C,Am,C})         % play chords on channel 2
%          sound(o,{2,C,Am,C})         % play chords on channel 2
%
%          sound(o,song(o,'c d e f g* g*'))
%
%       Options
%          tempo          % change play tempo (default: 100)
%          delay          % time delay (default: 1)
%          plot           % plot audio data (default: false);
%
%       See also:  MIDI, BAND
%
   plt = opt(o,{'plot',false});
   nin = nargin;
   
   if (nargin == 1)
      oo = o;                          % shift argument
      o = pull(o);                     % get shell object
      tempo = opt(o,{'player.tempo',100});

      o = opt(oo,'player.band');
      if isempty(o)
         o = new(o,'Piano');
      end
      
      tempo = get(oo,{'tempo',100}) * tempo/100;
      oo = set(oo,'tempo',tempo);
      
      PlaySound(o,oo);
      return
   elseif (nargin >= 2)
      oo = keys;                             % rename arg2 to oo
      PlaySound(o,oo);
      return
   end
      
      % otherwise play sound
      
   if ~type(o,{'band'})
      error('band object expected (arg1)');
   end
   
   if (nargin < 3)
      duration = 4 * ones(size(keys));
   end
   if (length(duration) == 1)
      duration = duration * ones(size(keys));
   end
   
   if (nargin < 4)
      channel = ones(size(keys));
   end
   if (length(channel) == 1)
      channel = channel * ones(size(keys));
   end
      
      % get list of instruments
      
   instruments = get(o,'list');
   
      % play sound
   
   for (i=1:length(keys))
      oo = instruments{channel(i)};
      Sound(oo,keys(i),duration(i),plt);    % play sound      
   end
   end

%==========================================================================
% Play Sound
%==========================================================================

function PlaySound(o,oo)
   if isa(oo,'midi')
      switch oo.type
         case 'midi'
            PlayMidi(o,oo);               % play MIDI music
         case 'note'
            PlayNote(o,oo);               % play note       
         case 'chord'
            PlayChord(o,oo);              % play chord       
         case 'song'
            PlayList(o,oo.data.list);     % play chord       
         otherwise
            error('bad object type expected for arg 2');
      end
   elseif iscell(oo)
      PlayList(o,oo);
   elseif ischar(oo)
      list  = music(o,oo);
      PlayList(o,list);
   else
      error('bad sound arg');
   end
end

%==========================================================================
% Sound Driver
%==========================================================================

function Sound(o,oo,t)                 % Play Sound Parameter Based       
   SoundChord(o,oo,t);
   
   function [wave,fs] = SoundChord(o,oo,t)
      assert(type(oo,{'note','chord'}));
      plt = opt(o,{'plot',false});
      tempo = get(oo,{'tempo',100});
      delay = get(o,{'player.delay',0});
      t = t*100/tempo;                 % scale time
      
         % get relevant data
         
      channel = oo.data.channel;
      key = oo.data.pitch - 20;
      duration = oo.data.duration;
      
         % process sound data
         
      for (i=1:length(channel))
         audio = o.par.list{max(1,channel(i))};
         [wavi,fsi] = SoundNote(audio,key(i),duration(i),plt);

         if (i == 1)
            wave = wavi;
            fs = fsi;
         else
            if (fsi ~= fs)
               error('cannot play chord with different samplig frequencies');
            end
            
            if all(size(wave) == size(wavi))
               wave = wave + wavi;
            else
               error('implementation');
            end
         end
      end
      
         % wait until time for sound output
         
      while (toc < t+delay)
         % wait
      end
      
          % no we can output sound
          
      sound(wave,fs);
   end
   function [wave,fs] = SoundNote(o,key,dur,plt)
      assert(type(o,{'audio'}));

      tempo = o.data.tempo;
      keys = o.data.keys;
      fs = o.data.fs;
      audio = o.data.audio;
      trim = o.data.trim;                 % trim factor

         % find index of dur, or if not found, index of shortest dur

      ndx = find(tempo==dur);
      if isempty(ndx)
         ndx = find(duration==min(tempo));
      end

         % find key index

      kdx = find(key==keys);
      if isempty(kdx)
         kdx = -1;              % don't play sound if key not found
      end

         % calculate length of audio chunk and cut out proper chunk

      m = length(keys);
      n = length(duration);

         % trim audio

      M = floor(length(audio)*(m*n)/(m*n+trim));
      audio = audio(1:M,:);

         % calculate segment and chunk indices


      N = size(audio,1)/(n*m);  
      sdx = (ndx-1)*m + kdx;              % segment index

      cdx = floor((sdx-1)*N) + (1:N);     % chunk indices
      if (kdx >= 0)
         wave = audio(cdx,:);             % wave data
      else
         wave = 0*audio(1:floor(N),:);
      end

         % play sound

      if (plt)
         clf;
         subplot(311);
         plot(1:length(audio),audio(:,1),'r');
         subplot(312);
         plot(1:length(wave),wave(:,1),'b');
         subplot(313);
         plot(1:length(wave),wave(:,2),'b');
      end

%     if (nargout == 0)
%        sound(wave,fs);
%     end
   end
end

%==========================================================================
% Play Note
%==========================================================================

function PlayNote(o,oo)                % Play Sound of a Note          
   Sound(o,oo,0);
end
function PlayChord(o,oo)               % Play Sound of a Chord         
   Sound(o,oo,0);
end

%==========================================================================
% Play Note
%==========================================================================

function PlayList(o,list)              % Play Sound of a List          
   if isempty(list)
      return                           % nothing left to do
   end
   
      % if list is a column we need to embed the column into a list
      
   if (size(list,1) > 1)               % column?
      list = {list};
   end
   
      % if first list item is a number or a string then we have to
      % eval the list
      
   first = list{1};
   if isa(first,'double') || ischar(first)
      list = eval(o,list);
   end
   
      % play sound of list
      
   song = Assemble(o,list);
   assert(size(list,1) <= 1);
   
   tic;                                % Start with zero time
   for (i=1:length(song))
      item = song{i};      
      t = item.data.time;
      Sound(o,item,t);
   end   
end

%==========================================================================
% Music Assembler
%==========================================================================

function list = Eval(o,args)           % Eval Expression               
   if ~(iscell(args) || isa(args,'midi'))
      error('cannot eval args');
   end
   
      % atoms must be notes and can be handeled heads-up
      
   if ~iscell(args)
      if type(args,{'note','chord'})
         list = args;
         return
      else
         error('bad type');
      end
   end
   
      % otherwise we process a list which can be a bit more tricky
      
   assert(iscell(args));
   if (size(args,1) <= 1)           % rows are processed 
      list = {};
   else
      list = args;                  % columns are passed through
      return
   end
   
      % process output list
      
   for (i=1:length(args))
      item = args{i};
      result = Eval(o,item);
      
      if ~iscell(result)
         list{end+1} = result;
      elseif size(result,1) == 1    % row
         list = [list,result];
      else                          % column will not expanded
         list{end+1} = chord(o,result);
      end
   end
end
function song = Assemble(o,list)       % Assemble Song                 
   time = 0;
   dt = 0;
   
   list = Eval(o,list);
   
   song = {};                          % init song as empty list of notes
   for (i=1:length(list))
      item = list{i};
      
      if isa(item,'midi')
         switch item.type
            case 'note'
               duration = item.data.duration;
               item.data.time = time;
               song{end+1} = item;
               time = time + duration;
            case 'chord'
               duration = item.data.duration;
               item.data.time = time;
               song{end+1} = item;
               time = time + max(duration);
            otherwise
               error('bad type');
         end
      elseif iscell(item)              % must be a  row cell
         assert(size(item,1) > 1);
         duration = 0;
         for (j=1:length(item))
            oo = item{i};
            if ~type(oo,{'note'})
               error('columns must contain only notes'); 
            end
            
            duration = max(duration,oo.data.duration);
            oo.data.time = time;
            song{end+1} = oo;
         end
         time = time + duration;
      end
   end
end

%==========================================================================
% Play MIDI music
%==========================================================================

function PlayMidi(o,oo)                % Play MIDI Music               
   assert(type(oo,{'midi'}));
   nmat = oo.data.nmat; 
   
   list = get(o,'list');               % list of channels
   
   tic;                                % Start with zero time
   for (i=1:size(nmat,1))
      note = nmat(i,:);
      t = note(6);
duration = 1;
      channel = note(3);
      key = note(4) - 20;
      velocity = note(5);
      
      if (channel > 0 && channel <= length(list))
         oo = list{channel};
         
            % wait until the right time tick to play
            
         while (t > toc)
            % wait
         end
         
         Sound(oo,key,duration);
      end
   end
end
