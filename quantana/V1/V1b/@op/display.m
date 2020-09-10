function display(obj)
%
% DISPLAY    Display an operator on Hilbert space
%
%          o = op('x');
%          display(o);
%
%       See also: OP
%
   fprintf(['<',obj.name,' ',obj.kind,'>\n']);
   
%eof   