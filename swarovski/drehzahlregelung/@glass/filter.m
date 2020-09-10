function y = filter(o,tag,Tf)
   if (nargin < 3)
      Tf = setting(o,{'plot.Tf',1.0});
   end
   
   Fs = trf(1,[Tf 1]);
   
   t = data(o,'t');
   x = delta(o,tag);
   
   y1 = rsp(Fs,x,t);
   
   xx = x(end:-1:1);  
   xx = xx-xx(1);           % start at zero
   yy = rsp(Fs,xx,t);
   y2 = yy(end:-1:1);
   y2 = y2-y2(1);
   
   y = (y1+y2)/2;
end