function oo = read(o,varargin)         % Read MIDI Object From File
%
% READ   Read a MIDI object from file.
%
%             oo = read(o,'ReadMidMid',path) % .mid data read driver
%
%          See also: MIDI, IMPORT
%
   [gamma,oo] = manage(o,varargin,@ReadMidMid);
   oo = gamma(oo);
end

%==========================================================================
% Read Driver for MIDI Data
%==========================================================================

function oo = ReadMidMid(o)             % Read Driver for .mid Data
   path = arg(o,1);
   [dir,file,ext] = fileparts(path);
   
   oo = midi('mid');
   oo.par.title = file;
   
   oo.par.dir = dir;
   oo.par.file = [file,ext];
   
   nmat = readmidi(path);
   oo.data.nmat = nmat;
end
