function oo = new(o,varargin)          % MIDI New Method              
%
% NEW   New MIDI object
%
%           oo = new(o,'Menu')         % menu setup
%
%           o = new(midi,'Laksin')    % some simple data
%
%       See also: MIDI, PLOT, ANALYSIS, STUDY
%
   [gamma,oo] = manage(o,varargin,@Laksin,@Menu);
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
% New Simple Object
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
             7.0000 1.7500 1.0000 66.0000 72.0000 4.2857 1.0714          ];
       
      % pack into object

   oo = midi('mid');                  % MIDI type
   oo.par.title = sprintf('Laksin (%s)',datestr(now));
   oo.data.nmat = nmat;
end

