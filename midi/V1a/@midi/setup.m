function list = setup(o)               % Setup Audio
%
% SETUP   Setup list of audio objects
%
%            list = setup(o)
%
%         Audio Support:
% 
%         See also: MIDI, AUDIO, SOUND
%
    list = {};
    
    list{end+1} = audio(o,'steinway-C4-C5-[32,1].wav',40:52,[32,1]);
end