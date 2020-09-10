function obj = pseudo(obj,q)
%
% PSEUDO   Pseudo function that transforms a harmonic oscillator into
%          a pseudo oscillator. The difference between a harmonic 
%          oscillator and a pseudo oscillator is, that die energy
%          eigenvalues are related:
%
%             E0, E1, E2, E3, ...     energy eigenvalues of harmonic osc.
%             E0^q, E1^q, E2^q, ...   energy eigenvalues of pseudo osc.
%
%          Syntax:
%
%             osc = harmonic(2,z);    % normal harmonic oscillator
%
%             osc = pseudo(osc,q)     % pseudo oscillator (q: real number)
%             osc = pseudo(osc,1.7)   % pseudo oscillator (q = 1.7)
%             osc = pseudo(osc)       % pseudo oscillator (q = 2)
%
%          See also: HARMONIC, WAVE
%
   if (nargin < 2)
      q = 2;
   end
   
   if (~isa(q,'double') | prod(size(q)) ~= 1)
      error('scalar number expected for pseudo factor!');
   end
   
   fmt = format(obj);
   dat = data(obj);
   par = get(obj);
   
   dat.pseudo = q;     % set pseudo factor
   
   obj = harmonic(fmt,par,dat);
   return

%eof