%
% WORD   Word automation functions
%
%    Create a Word Automation Server and make it visible on the screen.
%    This would be the equivalent of opening MS Word
%
%       oo = word(o,'Begin')           % begin new Word document
%       word(oo,'Add')                 % add current screen into Word doc
%       word(oo,'End')                 % end Word document
%
%    Note: the Active-X (Word-) handle is stored in var(o,'word.hdl')
%
%    Example
%       oo = word(o,'Begin')           % begin new Word document
%       cls(o)
%       plot(0:0.1:10,sin(0:0.1:10),'r');
%       title('Sine Curve');
%       oo = word(oo,'Add')            % add current screen to Word doc
%       word(oo,'End')                 % end Word document
%       
%    See also: CORAZON
%    Copyright (c): Bluenetics 2020 
%
