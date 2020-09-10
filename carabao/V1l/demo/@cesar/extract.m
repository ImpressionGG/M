function [out,x,y,img,ximg,yimg] = extract(o)
%
% EXTRACT   Extract data and image of fiducial area
%
%              [t,x,y,img,ximg,yimg] = extract(o)   % extract data and image
%              oo = extract(o)          % create caramel object with data
%
%           See also: CESAR
%
   oo = pick(o,'Fiducial');
   img = oo.data.image;
   
% %    idx = o.par.xrange(1):o.par.xrange(2);
% %    idy = o.par.yrange(1):o.par.yrange(2);
% %    img = o.data.image(idx,idy);
% %    oo = image(o,'Create',img);
   
   [m,n] = size(img);
   a = min(m,n);
   i1 = round(0.3*a);  i2 = round(0.7*a);
   
   ximg = img(i1:i2,1:a)';
   ox = image(o,'Create',ximg);

   yimg = img(1:a,i1:i2)';
   oy = image(o,'Create',yimg);
      
   assert(prod(size(ximg))==prod(size(yimg)));
   
   t = 1:prod(size(ximg));
   x = double(ximg(:))';
   yimg = yimg';
   y = double(yimg(:))';
   
   if (nargout <= 1)
      o = oo;                          % save o because of parameters
      oo = trace(caramel('image'),'t',t,'x',x,'y',y);
      oo.par.title = get(o,'title');
      oo.par.xlabel = get(o,'xlabel');
      oo.par.comment = get(o,'comment');
      [m,n] = size(ximg);
      oo.par.sizes = [1 m n];
      oo = inherit(oo,o);
      out = arg(oo,{});
   else
      out = t;
   end
end