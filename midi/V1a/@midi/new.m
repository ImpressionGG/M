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
%       Audio object
%
%           o = new(midi,'Steinway');  % steinway piano
%
%       Band object
%
%           o = new(midi,'Piano');    % 'band' with just one piano
%
%       Song object
%
%           o = new(midi,'CelloPreludium');
%           o = new(midi,'QuietNight');
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
   [gamma,oo] = manage(o,varargin,@Laksin,@Steinway,@Piano,@CelloPreludium,...
                       @QuietNight,@Menu);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Menu(o)                  % Setup Menu
   oo = mitem(o,'MIDI');
   ooo = mitem(oo,'Laksin',{@Callback,'Laksin'},[]);
   oo = mitem(o,'Audio');
   ooo = mitem(oo,'Steinway',{@Callback,'Steinway'},[]);
   oo = mitem(o,'Band');
   ooo = mitem(oo,'Piano',{@Callback,'Piano'},[]);
   oo = mitem(o,'Song');
   ooo = mitem(oo,'Cello Preludium',{@Callback,'CelloPreludium'},[]);
   ooo = mitem(oo,'Quiet Night',{@Callback,'QuietNight'},[]);
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
   oo.par.title = 'Laksin (MIDI Object)';
   oo.data.nmat = nmat;
end

%==========================================================================
% Audio Objects
%==========================================================================

function oo = Steinway(o)              % Steinway Grand Piano
   oo = audio(o,'steinway-C1-C8-[3200,100].wav',4:88,[32,1],0.31);
   oo.par.id = 'Steinway Grand Piano';
   oo.par.title = 'Steinway Grand Piano (Audio Object)';
end

%==========================================================================
% Band Objects
%==========================================================================

function oo = Piano(o)                 % Steinway Grand Piano
   oo = band(midi,{'Steinway Grand Piano'});
   oo.par.title = 'Steinway Grand Piano (Audio Object)';
end

%==========================================================================
% Song Objects
%==========================================================================

function oo = CelloPreludium(o)
   cello1 = 'g- d- b- a- b- d- b- d- ';
   cello2 = 'g- e- c  b- c  e- c  e- ';
   cello3 = 'g- f#- c  b- c  f#- c  f#- ';
   cello4 = cello1;                          % not exactly
   
   oo = song(o,[cello1 cello1,cello2 cello2, cello3 cello3,cello4 cello4]);
   oo.par.title = 'Bach''s Cello Preludium (Sequence)';
end
function oo = QuietNight(o)
%
% from Soothing Relaxation
% 'Quiet Night - Tiefschlafmusik mit Schwarzem Bildschirm'
%
   e = -3;  a = -6;  d = -2;  g = 5;  c = 1;  f = 4;
   
   s1 = [a d g c f g e f g c c f c f g e f g];
   s2 = [c a f g a f g  c f d g f a c d g e a d g  f g f g  c f g e f g c];
   s3 = [a f g c a f g  a d g c f g e f g f c f g e f g c a f c f d g f];
   s4 = [a c d];
   
   oo = chord(o,[s1 s2 s3 s4]);
   oo.par.title = 'Quiet Night (Sequence)';
end
