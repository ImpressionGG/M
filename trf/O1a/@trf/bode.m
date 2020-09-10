function oo = bode(o,col)
%
% BODE     Bode plot of a TRF object (transfer function)
%
%             G = trf([2 4],2*[1 2]);
%             bode(G,'r');
%
%          See also: TRF, TRIM, DSP, STEP
%
   oo = pull(o);
   if isempty(oo)
      launch(o);
   end
   
   if container(o)
      list = o.data;
   else
      list = {o};
   end
   
   for (i=1:length(list))
      oo = list{i};
      if o.is(type(oo),{'strf','ztrf','qtrf'})
         if (nargin < 2)
            col = o.either(get(oo,'color'),'c');
         end

         Bode(oo,col);
      end
   end
   
   tit = get(o,'title');
   if (isempty(tit))
      title('Bode Plot');
   else
      title(['Bode Plot: ',tit]);
   end
   oo = o;
end

%==========================================================================
% Actual Bode Plot
%==========================================================================

function o = Bode(o,mcolor,pcolor,arg4)
%
% tffbode Draw Bode plot of a transfer function
%
%       Bode(o)
%	     Bode(o,'r')      ... select RED for both magnitude and phase
%	     Bode(o,'r','g')  ... select RED for magnitude and GREEN for phase
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

   label = get(o,{'title',''});
%  if ( isstr(G) )
%     label = G;
%     if ( Nargin >= 2 ) 
%        G = mcolor; 
%     else
%        error('missing argument (arg2)');
%     end
%     if ( Nargin >= 3 ) mcolor = pcolor; end
%     if ( Nargin >= 4 ) pcolor = arg4; end
%     Nargin = Nargin - 1;
%  end

   G = o.data;                         % fetch transfer function data
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

