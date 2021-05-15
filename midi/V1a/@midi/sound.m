function sound(o,keys,notes,channel)
%
% SOUND Play sound on a specific instrument based on an audio typed
%       MIDI object. First argument must be a 'band'  typed object.
%
%          oo = band(o,{'Steinway Grand Piano'});
%          sound(oo,keys,notes,channels)
%
%       Options
%          plot           % plot audio data (default: false);
%
%       See also:  MIDI, BAND
%
   if ~type(o,{'band'})
      error('band object expected (arg1)');
   end
   
   if (nargin < 3)
      notes = 4 * ones(size(keys));
   end
   if (length(notes) == 1)
      notes = notes * ones(size(keys));
   end
   
   if (nargin < 4)
      channel = ones(size(keys));
   end
   if (length(channel) == 1)
      channel = channel * ones(size(keys));
   end
   
   plt = opt(o,{'plot',false});
   
      % get list of instruments
      
   instruments = get(o,'list');
   
      % play sound
   
   for (i=1:length(keys))
      oo = instruments{channel(i)};
      Sound(oo,keys(i),notes(i),plt);    % play sound      
   end
end

%==========================================================================
% Play Sound
%==========================================================================

function Sound(o,key,note,plt)
   assert(type(o,{'audio'}));
   
   notes = o.data.notes;
   keys = o.data.keys;
   fs = o.data.fs;
   audio = o.data.audio;
   trim = o.data.trim;                 % trim factor
   
      % find index of note, or if not found, index of shortest note
      
   ndx = find(notes==note);
   if isempty(ndx)
      ndx = find(notes==max(notes));
   end
   
      % find key index
      
   kdx = find(key==keys);
   if isempty(kdx)
      return                           % don't play sound if key not found
   end
   
      % calculate length of audio chunk and cut out proper chunk
      
   m = length(keys);
   n = length(notes);

      % trim audio
      
   M = floor(length(audio)*(m*n)/(m*n+trim));
   audio = audio(1:M,:);
   
      % calculate segment and chunk indices
      
  
   N = floor(size(audio,1)/(n*m));  
   sdx = (ndx-1)*m + kdx;              % segment index
   
   cdx = (sdx-1)*N + (1:N);            % chunk indices
   wave = audio(cdx,:);                % wave data
   
      % play sound

   if (plt)
      clf;
      subplot(211);
      plot(1:length(wave),wave(:,1),'r');
      subplot(212);
      plot(1:length(wave),wave(:,2),'b');
   end
      
   sound(wave,fs);
end

