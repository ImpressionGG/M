function tffstep(G,col,arg3)
%
% TFFSTEP Plot step response of a transfer function:
%
%            TFFSTEP(G)
%            TFFSTEP(G,color)
%            TFFSTEP('G(s)',G,color)
%
%	  If color is not specified, a default value will be
%	  taken. 
%
%         See also TIMEAXES, TFFNEW
%
   Nargin = nargin;   % copy (modify later)

   label = '';
   if ( isstr(G) )
      label = [' ',G];
      if ( Nargin >= 2 ) G = col; else error('missing argument (arg2)'); end
      if ( Nargin >= 3 ) col = arg3; end
      Nargin = Nargin - 1;
   end

   G = tfftrim(G);
   [class,kind] = ddmagic(G);

   if ( kind == 3 )
      G = tffztf(G);
      [class,kind] = ddmagic(G);
   end

   l = max(size(G));
   if (G(1) < 0) G(1) = -G(1);	G(2,:) = -G(2,:); end
   num = G(1,2:l);
   den = G(2,2:l);
   Ts = G(2);

   timeaxes;                 % select (or create) time axes
   xlim = get(gca,'xlim');

   nextplot=get(gca,'nextplot');    % save settings

   if ( strcmp(nextplot,'replace') )
      set(gca,'nextplot','add');
      delete(get(gca,'children'));
   end

      % handle semiautomatic axes limits


   if ( isinf(xlim(2)) )

      if ( kind == 1)
         rden = roots(den);  rnum = roots(num);   
         delta = sort(abs(real([rden(:).', rnum(:).'])));

         while ( ~isempty(delta) )
            if ( delta(1) > eps*1000 ) break; end
            delta(1) = [];
         end
            
         if ( isempty(delta) )
            xlim(2) = 10;
         else
            xlim(2) = 5*1/delta(1);
         end
      else
         xlim(2) = 50*Ts; 
      end

   end


      % setup time limits


   TfTimeLo  = xlim(1);  TfTimeHi  = xlim(2);

   TfLinearPoints = 100;
   %TfLinearPoints = 2000;

   if ( kind == 1)
      t = TfTimeLo:(TfTimeHi-TfTimeLo)/TfLinearPoints:TfTimeHi;
      y = steprsp(num,den,t);

      if ( Nargin == 2 )
         hdl = plot(t,y,col);
      else
         hdl = plot(t,y);
      end
   elseif ( kind == 2 )
      n = (TfTimeHi-TfTimeLo) / Ts;
      t = TfTimeLo:(TfTimeHi-TfTimeLo)/n:TfTimeHi;
      y = dstep(num,den,n+1);

      if ( Nargin == 2 )
         if ( strcmp(col,'|') )
            hdl = tffstem(t,y);
         else
            hdl = tffstem(t,y,col);
         end
      else
         hdl = tffstem(t,y);
      end
   elseif ( kind == 3 )
      Hz = ZTF(G);
      m = max(size(Hz));
      num = Hz(1,2:m);
      den = Hz(2,2:m);

      n = (TfTimeHi-TfTimeLo) / Ts;
      t = TfTimeLo:(TfTimeHi-TfTimeLo)/n:TfTimeHi;
      y = dstep(num,den,n+1);
      hdl = stem(t,y,col);
   end

   set(hdl,'userdata',['Step Response',label]);
   set(gca,'nextplot',nextplot);
end
