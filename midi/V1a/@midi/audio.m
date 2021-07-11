function oo = audio(o,file,keys,tempo,trim)
%
% AUDIO  Read audio data file
%
%           oo = audio(o,file,keys,tempo,trim);
%
%           oo = audio(o,'steinway-C1-C8-[3200,100].wav',4:88,[3200,100],0.31);
%           oo = audio(o,'steinway-C4-C5-[3200,100].wav',60:72,[3200,100],0.31);
%           sdat = data(oo,'audio');          % get audio data
%
%        Auxillary funtions
%
%           audio(o,'Plot');
%
%        Note (key numbers)
%            C4      key 60
%            C4#     key 61
%            D4      key 62
%            D4#     key 63
%            E4      key 64
%            F4      key 65
%            F4#     key 66
%            G4      key 67
%            G4#     key 68
%            A4      key 69    (440 Hz)
%            A4#     key 70
%            B4      key 71
%            C5      key 72
%
%        See also: MIDI, SOUND
%
   if (nargin < 5)
      trim = 0;
   end
   
   if (nargin == 2)
      mode = file;
      oo = [];
      
      switch mode
         case 'Plot'
            Plot(o);
         otherwise
            error('bad mode');
      end
      return
   end
   
   path = which('midi');
   
      % generate directory path for wave data
      
   idx = strfind(path,'@');
   dir = [path(1:idx-1),'sound'];
   path = [dir,'/',file];
   
   idx = strfind(lower(file),'.wav');
   title = file(1:idx-1);
   
      % read audio file
      
   [audio,fs] = audioread(path);
   
      % create MIDI object
      
   oo = midi('audio');
   oo.data.audio = audio;
   oo.data.fs = fs;
   oo.data.keys = keys;
   oo.data.tempo = tempo;
   
      % set parameters
      
   oo.par.title = title;
   oo.par.comment = {'Audio Data'};
   oo.par.file = file;
   oo.par.dir = dir;
   
      % setup indices
      
   oo = Setup(oo,trim);                % setup indices
end

%==========================================================================
% Setup Index
%==========================================================================

function o = Setup(o,trim)             % Setup Indices
   assert(type(o,{'audio'}));

   tempo = o.data.tempo;
   keys = o.data.keys;
   fs = o.data.fs;
   audio = o.data.audio;
   o.data.trim = trim;                 % trim factor

      % calculate length of audio chunk and cut out proper chunk

   m = length(o.data.keys);
   n = length(o.data.tempo);

      % trim audio

   M = floor(length(audio)*(m*n)/(m*n+trim));
   audio = audio(1:M,:);
   o.data.audio = audio;

      % calculate segment and chunk indices


   for (ndx = 1:n)
      for (kdx = 1:m)
         N = size(audio,1)/(n*m);  
         sdx = (ndx-1)*m + kdx;              % segment index

         cdx = floor((sdx-1)*N + [1,N]);     % chunk indices
         index(kdx,(1:2)+(ndx-1)*2) = cdx;
      end
   end
   
   o.data.index = index;
end

%==========================================================================
% Plot Audio Content
%==========================================================================

function o = Plot(o)
   o = inherit(o,sho);
   assert(type(o,{'audio'}));

      % get first key and last key
      
   key1 = o.data.keys(1);
   key2 = o.data.keys(end);
   
      % get indices
      
   c1 = o.data.index(:,1:2:end-1);
   c2 = o.data.index(:,2:2:end);
   cmin = min(c1);  cmax = max(c2);
   
   wave = o.data.audio;
    
   m = length(o.data.keys);
   n = length(o.data.tempo);
   
   cls(o);
   for (k=1:n)
      index = cmin(k):cmax(k);
      keys = key1 + [index-index(1)]*(1+key2-key1)/(length(index)-1);

      PlotWave(o,[n 1 k],keys,wave(index,1),'g');
      hold on;
      PlotWave(o,[n 1 k],keys,wave(index,2),'r');
   end
   closeup(o);
   heading(o);
   
   function PlotWave(o,sub,x,y,col)
      subplot(o,sub);
      
      
      plot(x,y,col);
      hold on;

      ylim = get(gca,'ylim');
      for (i=1:m)
         for (j=1:2:n)
            plot(o,x(c1(i,j))*[1 1],ylim,'kw');
            plot(o,x(c2(i,j))*[1 1],ylim,'kw');
         end
      end
      subplot(o);
   end
end
