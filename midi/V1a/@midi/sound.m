function sound(o,keys,duration,channel)
%
% SOUND Play sound on a specific instrument based on an audio typed
%       MIDI object. First argument must be a 'band'  typed object.
%
%          oo = band(o,{'Steinway Grand Piano'});
%          sound(oo,keys,duration,channels)
%
%       In case of oo is a midi object
%
%          o = band(midi,{'Steinway Grand Piano'});
%          oo = new(o,'Laksin');
%          sound(o,oo)
%
%       Options
%          plot           % plot audio data (default: false);
%
%       See also:  MIDI, BAND
%
   plt = opt(o,{'plot',false});

   if isequal(class(keys),'midi')
      oo = keys;         
      if ~type(oo,{'midi'})
         error('midi type expected for arg 2');
      end
      
      Midi(o,oo);                      % play MIDI music
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

function Sound(o,key,dur,plt)
   assert(type(o,{'audio'}));
   if (nargin < 4)
      plt = false;
   end
   
   duration = o.data.duration;
   keys = o.data.keys;
   fs = o.data.fs;
   audio = o.data.audio;
   trim = o.data.trim;                 % trim factor
   
      % find index of dur, or if not found, index of shortest dur
      
   ndx = find(duration==dur);
   if isempty(ndx)
      ndx = find(duration==max(duration));
   end
   
      % find key index
      
   kdx = find(key==keys);
   if isempty(kdx)
      return                           % don't play sound if key not found
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
   wave = audio(cdx,:);                % wave data
   
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
      
   sound(wave,fs);
end

%==========================================================================
% Play MIDI music
%==========================================================================

function Midi(o,oo)                    % Play MIDI Music               
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