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
% - Toolbox to analyse and study ...
%
%--------------------------------------------------------------------------
%
% Roadmap
% =======
% - roadmap item 1
% - roadmap item 2
% - roadmap item ...
%
%--------------------------------------------------------------------------
%
% Release Notes MIDI/V1A
% =======================
%
% - created: 15-May-2021 00:41:24
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
