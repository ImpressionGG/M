function oo = quad(o,number)
%
% QUAD   Create a quad chord, according to the quadchord number
%
%           oo = quad(o,number) 
%
%        Let
%           dominant: 0 or 1
%           second:   1 to 7
%           third:    1 to 7
%
%        Then
%           number = 2*[(second-1)*7 + (third-1)]
%
%        In total there are 6*6*2 = 72 such quadchords
%
%        Example
%           0:    1-1-1-4
%           1:    1-1-1-5
%           2:    1-1-2-4
%           3:    1-1-2-5
%           :        :
%           68:   1-6-5-4
%           69:   1-6-5-5
%           70:   1-6-6-4
%           71:   1-6-6-5
%
%        See also MIDI, SOUND, CHORD
%
   number = rem(number,7*7*2);
   seq = Sequence(o,number);
   
   for (i=1:length(seq))
      list{i} = chord(o,seq(i));
   end
   
   oo = song(o,list);
   oo.par.title = sprintf('quadcord #%g [%g,%g,%g,%g]',number,...
                     seq(1),seq(2),seq(3),seq(4));
end

function seq = Sequence(o,number)
   n4 = rem(number,2);
   number = (number-n4) / 2;
   
   n3 = rem(number,6);
   number = (number-n3) / 6;
   
   n2 = rem(number,6);
   
   if (any(n2==[1 4 5]))
      n2 = n2+1;
   else
      n2 = -n2-1;
   end

   if (any(n3==[1 4 5]))
      n3 = n3+1;
   else
      n3 = -n3-1;
   end
   
   seq = [1 n2 n3 o.iif(n4,5,4)];
end
