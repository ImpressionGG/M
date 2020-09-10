function tffphase(G,col,arg3)
%
% TFFPHASE Phasetude plot a transfer function's frequency response.
%
%        tffphase(G)
%	      tffphase(G,col)
%	      tffphase('G(s)',G,col)
%
%	   draws the phase plot of a transfer functions frequency
%          response G(jw). The second argument (color of the plot) is
%          optional.
%
%	   See also TFFNEW, BODEAXES, TFFMAGNI
%
   Nargin = nargin;       % copy - modify later
   
   label = '';
   if ( isstr(G) )
      label = [' ',G];
      if ( Nargin >= 2 ) G = col; else error('missing argument (arg2)'); end
      if ( Nargin >= 3 ) col = arg3; end
      Nargin = Nargin - 1;
   end

   hax = bodeaxes;
   xlim = get(hax,'xlim');
   ylim = get(hax,'ylim');
   zlim = get(hax,'zlim');

   TfBodePoints = 100;
   TfOmegaLo = xlim(1);    y1 = ylim(1);   z1 = zlim(1);
   TfOmegaHi = xlim(2);    y2 = ylim(2);   z2 = zlim(2);


   om = logspace(log10(TfOmegaLo),log10(TfOmegaHi),TfBodePoints);
   [ma,ph] = tfffqr(G,om,z1,z2);


   Ph = y1 + (y2-y1)/(z2-z1) * (ph-z1);

   if ( Nargin < 2 )
      hdl = semilogx(om,Ph);
   else
      %hdl = semilogx(om,Ph,col);
      hdl = semilogx(om,Ph,'k--');
      if isstr(col) && length(col) > 2 && col(end-1) == '-' && col(end) == '-'
         col = col(1:end-2);
      end
      carabao.color(hdl,col);
   end

   set(hdl,'userdata',['Phase',label]);

%   hold off;

% eof
