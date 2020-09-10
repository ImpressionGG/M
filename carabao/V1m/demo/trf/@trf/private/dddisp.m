function dddsp(obj,message)
%
% DDDSP   Data directed display of a DD instance.
%
%            dsp(obj) 
%            dsp(G,'G(s)') 
%
%         The second argument is a text argument which may be used
%         by a particular display function.
%
%         See also: ddclass, ddmagic
%

   if ( nargin == 0 )
      error('argument missing');
   elseif ( nargin == 1 )
      ddcall('disp',0,obj)
   else
      ddcall('disp',0,obj,message)
   end

% eof

