function tffbode(G,mcolor,pcolor,arg4)
%
% tffbode Draw Bode plot of a transfer function
%
%       tffbode(G)
%	     tffbode(G,'r')      ... select RED for both magnitude and phase
%	     tffbode(G,'r','g')  ... select RED for magnitude and GREEN for phase
%	     tffbode('G(s)',G)
%
%	  Draws the bode plot  (magnitude and phase) of the
%	  transfer function G. Optionally the colors of the
%	  plots may be	specified too.
%
%         See also: TFFNEW, TFFMAGNI, TFFPHASE
%
   Nargin = nargin;       % copy - modify later
   
   if (Nargin == 0)
      bodeaxes;
      return
   end

   label = '';
   if ( isstr(G) )
      label = G;
      if ( Nargin >= 2 ) 
         G = mcolor; 
      else
         error('missing argument (arg2)');
      end
      if ( Nargin >= 3 ) mcolor = pcolor; end
      if ( Nargin >= 4 ) pcolor = arg4; end
      Nargin = Nargin - 1;
   end

   G = tfftrim(G);

      % Do not use 'ma = bode(num,den,om);'

   if ( Nargin == 1 )

      tffmagni(G);
      tffphase(G,'--');

   elseif ( Nargin == 2 )
      if ( isstr(mcolor) )
         if ( all(mcolor~='-') ) pcolor = [mcolor,'--']; end
      end

      tffmagni(label,G,mcolor);
      tffphase(label,G,pcolor);

   elseif ( Nargin == 3 )

      tffmagni(label,G,mcolor);
      tffphase(label,G,pcolor);

   else
      error('Too many input arguments');
   end
end

