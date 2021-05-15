function oo = audio(o,file,keys,notes)
%
% AUDIO  Read audio data file
%
%           oo = audio(o,'steinway-C4-C5-[32,1].wav',40:52,[32,1]);
%           sdat = data(oo,'audio');          % get audio data
%
%        Note (key numbers)
%            C4      key 40
%            C4#     key 41
%            D4      key 42
%            D4#     key 43
%            E4      key 44
%            F4      key 45
%            F4#     key 46
%            G4      key 47
%            G4#     key 48
%            A4      key 49    (440 Hz)
%            A4#     key 50
%            B4      key 51
%            C5      key 52
%
%        See also: MIDI, SOUND
%
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
   oo.data.notes = notes;
   
      % set parameters
      
   oo.par.title = title;
   oo.par.comment = {'Audio Data'};
   oo.par.file = file;
   oo.par.dir = dir;
end
