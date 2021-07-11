function vers = version(o,arg)       % MIDI Class Version
%
% VERSION   MIDI class version / release notes
%
%       vs = version(midi);            % get MIDI version string
%
%    See also: MIDI
%
%--------------------------------------------------------------------------
%
% Features MIDI/V1A
% ==================
%
% - MIDI Toolbox to play with audio
%
%--------------------------------------------------------------------------
%
% Roadmap
% =======
% + basic objects (types: midi, audio, band, note)
% + 3-octave implementation of Steinway Grand Piano
% + sound playing based on lists
% + simultaneous sound playing of chords
% - sound method to play MIDI matrix
% - export MIDI object to .mid file
% - music method to translate text to lists
% - list evaluation in general
% - list evaluation based on Bach's Prelude
%
%--------------------------------------------------------------------------
%
% Release Notes MIDI/V1A
% =======================
%
% - created: 15-May-2021 00:41:24
% + basic objects (types: midi, audio, band, note)
% + 3-octave implementation of Steinway Grand Piano
% + sound playing based on lists
% + simultaneous sound playing of chords :-)))
% - begin of Bach cello prelude
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('midi/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@MIDI'));
   vers = path(idx-4:idx-2);
end
