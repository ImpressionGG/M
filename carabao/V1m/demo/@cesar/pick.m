function oo = pick(o,varargin)
%
% PICK   Pick image according to options. Set parameter fiducial
%
%           oo = pick(o,'Area')        % pick fiducial area
%           oo = pick(o,'Fiducial')    % pick fiducial
%
%        Return a CARAVEL object
%
%        See also: CESAR, PLOT, EXTRACT
%
   [gamma,oo] = manage(o,varargin,@Fiducial,@Area);
   oo = gamma(oo);
end

%==========================================================================
% Local Functions
%==========================================================================

function oo = Fiducial(o)
   oo = Pick(o);                       % copy fiducial option
   oo.data.image = oo.par.fiducial;
end
function oo = Area(o)
   oo = Pick(o);                       % copy fiducial option
   oo.data.image = oo.par.area;
end
function oo = Pick(o)
   oo = cast(o,'caravel');
   fid = opt(o,'fiducial');
   if isempty(fid)
      error('cannot deal with empty fiducial option!');
   end
   area = fid.area;  
   w = fid.image.w;                    % fiducial image width
   h = fid.image.h;                    % fiducial image height
   aw = w * area.n;                    % area width [pixels]
   ah = h * area.m;                    % area height [pixels]
   
   img = o.data.image;
   [m,n] = size(img);
   
      % pick area image
      
   i0 = min(max(1,area.x),m);
   i1 = min(max(i0,i0+aw-1),m);

   j0 = min(max(1,area.y),n);
   j1 = min(max(j0,j0+ah-1),n);
   
   oo.par.area = img(i0:i1,j0:j1);     % area image
   atxt = sprintf('[%g,%g],[%g,%g]',i0,i1,j0,j1);
   
      % pick fiducial image
      
   index = fid.index;
   i0 = min(max(1,1+(index.i-1)*h),ah);
   i1 = min(max(i0,i0+h-1),ah);

   j0 = min(max(1,1+(index.j-1)*w),aw);
   j1 = min(max(j0,j0+w-1),aw);
   
   oo.par.fiducial = oo.par.area(i0:i1,j0:j1);     % area image
   ftxt = sprintf('[%g,%g],[%g,%g]',i0,i1,j0,j1);

   tit = get(oo,{'title',''});
   oo.par.xlabel = sprintf('image: %gx%g, area: %s,  fiducial: %s, index: [%g,%g]',...
                           m,n,atxt,ftxt,index.i,index.j);
end
