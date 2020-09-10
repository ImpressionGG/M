function hdl = tffmagni(G,col,arg3)
%
% TFFMAGNI Magnitude plot a transfer function's frequency response.
%
%             tffmagni(G)
%	      tffmagni(G,col)
%	      tffmagni('G(s)',G,col)
%
%	   draws the magnitude plot of the transfer functions frequency
%          response G(jw). The second argument (color of the plot) is
%          optional.
%
%	   See also TFFNEW, BODEAXES, TFFPHASE
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

   TfBodePoints = 100;
   TfOmegaLo = xlim(1);
   TfOmegaHi = xlim(2);

   om = logspace(log10(TfOmegaLo),log10(TfOmegaHi),TfBodePoints);
   ma = tfffqr(G,om);

   if ( Nargin < 2 )
      hdl = semilogx(om,20*log10(ma));
   else
      %hdl = semilogx(om,20*log10(ma),col);
      hdl = semilogx(om,20*log10(ma),'k');
      corazon.color(hdl,col);
   end

   set(hdl,'userdata',['Magnitude',label]);
end

