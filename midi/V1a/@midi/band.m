function oo = band(o,instruments)      % Setup Band
%
% BAND    Setup band with instruments. Second arg is a list of identifiers
%         for the particular MIDI channels
%
%            oo = band(o,{'Steinway Grand Piano'});
%            oo = band(o,{'Steinway Grand Piano','Volin'});
%
%         Short setup for default band:
%
%            oo = band(o);             % setup default band
%
%         Supported Instruments
%            'Steinway Grand Piano'    ('SWGP')
% 
%         See also: MIDI, AUDIO, SOUND
%
    if (nargin < 2)
       instruments = {'Steinway Grand Piano'};
    end
    
    for (i=1:length(instruments))
       oo = Instrument(o,instruments{i});
       oo.par.channel = i;
       list{i} = oo;
    end
    
    oo = midi('band');
    
    oo.data = [];
    oo.par.instruments = instruments;
    oo.par.list = list;
    oo.par.tempo = 100;
end

%==========================================================================
% Setup Instrument
%==========================================================================

function oo = Instrument(o,id)
   switch id
      case 'Steinway Grand Piano'
%        oo = audio(o,'steinway-C4-C5-[32,1].wav',40:52,[32,1]);
%        oo.data.trim = 0.63;
         oo = audio(o,'steinway-C3-C6-[32,1].wav',28:64,[32,1]);
         oo.par.id = 'Steinway Grand Piano';
         oo.data.trim = 0.31;
         
      otherwise
         oo = [];
   end
   
      % provide zero trim factor if missing (used for sound chunk
      % generation)
      
   if isempty(data(oo,'trim'))
      oo.data.trim = 0;
   end
end
