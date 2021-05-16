function oo = new(o,varargin)          % MIDI New Method              
%
% NEW   New MIDI object
%
%           oo = new(o,'Menu')         % menu setup
%
%       MIDI data object
%
%           o = new(midi,'Laksin')    % some simple data
%
%       Band object
%
%           o = new(midi,'Piano');    % 'band' with just one piano
%
%       Song object
%
%           o = new(midi,'CelloPreludium');
%
%       Description of MIDI columns (beat unit is ticks per quarter note)
%
%          1: onset (beats)
%          2: duration (beats)
%          3: MIDI channel
%          4: MIDI pitch (pitch = key+20, e.g. C4 key = 40, C4 pitch = 60)
%          5: velocity (how fast is key of note pressed, i.e loudness)
%          6: onset (seconds)
%          7: duration (seconds)
%
%       MIDI file example (Laksin)
%
%          0.0  0.9000   1    64  82    0.0000  0.5510
%          1.0  0.9000   1    71  89    0.6122  0.5510
%          2.0  0.4500   1    71  82    1.2245  0.2755
%          2.5  0.4500   1    69  70    1.5306  0.2755
%          3.0  0.4528   1    67  72    1.8367  0.2772
%          3.5  0.4528   1    66  72    2.1429  0.2772
%          4.0  0.9000   1    64  70    2.4490  0.5510
%          5.0  0.9000   1    66  79    3.0612  0.5510
%          6.0  0.9000   1    67  85    3.6735  0.5510
%          7.0  1.7500   1    66  72    4.2857  1.0714 
%          
%       See also: MIDI, PLOT, ANALYSIS, STUDY
%
   [gamma,oo] = manage(o,varargin,@Laksin,@Piano,@CelloPreludium,@Menu);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Menu(o)                  % Setup Menu
   oo = mitem(o,'Laksin',{@Callback,'Laksin'},[]);
end
function oo = Callback(o)
   mode = arg(o,1);
   oo = new(o,mode);
   paste(o,oo);                        % paste object into shell
end

%==========================================================================
% MIDI Objects
%==========================================================================

function oo = Laksin(o)                % New wave object
   nmat = [ 
             0      0.9000 1.0000 64.0000 82.0000 0      0.5510
             1.0000 0.9000 1.0000 71.0000 89.0000 0.6122 0.5510
             2.0000 0.4500 1.0000 71.0000 82.0000 1.2245 0.2755
             2.5000 0.4500 1.0000 69.0000 70.0000 1.5306 0.2755
             3.0000 0.4528 1.0000 67.0000 72.0000 1.8367 0.2772
             3.5000 0.4528 1.0000 66.0000 72.0000 2.1429 0.2772
             4.0000 0.9000 1.0000 64.0000 70.0000 2.4490 0.5510
             5.0000 0.9000 1.0000 66.0000 79.0000 3.0612 0.5510
             6.0000 0.9000 1.0000 67.0000 85.0000 3.6735 0.5510
             7.0000 1.7500 1.0000 66.0000 72.0000 4.2857 1.0714 
          ];
       
      % pack into object

   oo = midi('midi');                  % MIDI type
   oo.par.title = sprintf('Laksin (%s)',datestr(now));
   oo.data.nmat = nmat;
end

%==========================================================================
% Band Objects
%==========================================================================

function oo = Piano(o)                 % Steinway Grand Piano
   oo = band(midi,{'Steinway Grand Piano'});
end

%==========================================================================
% Song Objects
%==========================================================================

function oo = CelloPreludium(o)
   cello1 = 'g- d- b- a- b- d- b- d- ';
   cello2 = 'g- e- c  b- c  e- c  e- ';
   cello3 = 'g- f#- c  b- c  f#- c  f#- ';
   cello4 = cello1;                          % not exactly
   
   oo = [cello1 cello1, cello2 cello2, cello3 cello3, cello4 cello4 ];
end
