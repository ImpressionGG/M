classdef midi < corazon                % Midi Class Definition
%
% MIDI   Corazon Class Midi, objects to deal with MIDI music
%
%        Object types
%           midi:           MIDI object, cotaining MIDI data
%           audio:          Audio object, representing a MIDI instrument
%           band:           Band object, a collection of audio objects
%           note:           Note object, representing one/more MIDI notes
%           chord:          representating a chord relative to a scale
%
%        See also: MIDI, NEW, AUDIO, BAND, NOTE, CHORD
%
   methods                             % public methods
      function o = midi(arg)           % midi constructor
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@corazon(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name

         if (nargout == 0)
            launch(o);
            clear o;
         end
      end
   end
end
