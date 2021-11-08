function oo = post(o)
%
% POST    Post a message through a mesh channel with repeat count r
%
%            oo = post(o,r)
%
%         Input object type must be send, output object type 'xmit'
%         (transmission)
%
%         Copyright(c): Bluenetics 2021
%
%         See also: MESH, NEW
%
   if ~type(o,{'send'})
      error('input object (arg1) must be type "send"');
   end

   [L,A,B,D,R0] = phy(o); 

   [t,ID] = data(o,'t,ID');
end
