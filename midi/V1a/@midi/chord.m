function song = chord(o,sym)
%
% CHORD  Return source text for a chord
%
%           song = chord(o,'C')
%           song = chord(o,'G')
%           song = chord(o,'F')
%
%        Relative chords
%
%           o = set(midi,'scale','C');           % C major scale
%
%           song = chord(o,'@1')                 % C major scale: 'ceg'
%           song = chord(o,'$2')                 % D minor scale: 'dfa'
%           song = chord(o,'$3')                 % E minor scale: 'egb'
%           song = chord(o,'@4')                 % F major scale: 'fac'
%           song = chord(o,'@5')                 % G major scale: 'gbc'
%           song = chord(o,'$6')                 % A minor scale: 'ace'
%           song = chord(o,'$7')                 % B minor scale: 'bdf'
%
   switch (sym)
      case '@1'
         song = 'ceg';
      case '@2'
         song = 'df#a';
      case '@3'
         song = 'eg#b';
      case '@4'
         song = 'fac';
      case '@5'
         song = 'gbc';
      case '@6'
         song = 'ac#e';
      case '@7'
         song = 'bd#f';

      case '$1'
         song = 'ce°g';
      case '$2'
         song = 'dfa';
      case '$3'
         song = 'egb';
      case '$4'
         song = 'fa°c';
      case '$5'
         song = 'gb°c';
      case '$6'
         song = 'ace';
      case '$7'
         song = 'bdf';
   end
end