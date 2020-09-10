function [idx,cdx,t] = crowd(o,a)                                      
%
% CROWD  Find indices of crowds, to identify interesting time intervals
%        of each facette cutting.
%
%           idx = crowd(o,a) 
%
%        With two output ars fetch current object from o and return crowd
%        indices. Also prepare an epilog option
%
%           [oo,cdx] = crowd(o)
%           epilog = opt(oo,'epilog')
%
%        See also: CUT
%
   if (nargout >= 2 && nargin == 1)
      if (nargout == 2) 
         [oo,cdx] = Crowd(o);
      elseif (nargout == 3)
         [oo,cdx,t] = Crowd(o);
      end
      idx = oo;              % rename out arg
      return;
   end
   
   t = o.data.t;
   if (nargin < 2)
      a = sqrt(o.data.ax.^2+o.data.ay.^2);
   end
   
   if any(size(t)~=size(a))
      error('sizes of a and t do not match!');
   end

   f = abs(a);
   fsort = sort(f);
   
   fm = fsort(floor(length(fsort)*0.9));
   jdx = find(f>=fm);

      % calculate didd function d
   
   d = diff(jdx);
   cdx = find(d > max(d)/10);   % cluster indices
   cdx = [cdx; (cdx+1)];
   cdx = [1, cdx(:)', length(jdx)];
   kdx = jdx(cdx);
   
   %cls(o);
   for (i=1:length(kdx)/2)      
      bmin = kdx(2*i-1);
      bmax = kdx(2*i);
      db = floor((bmax-bmin)*0.5);

      bmin = max(bmin-db,1);
      bmax = min(bmax+db,length(a));
      
      idx(i,:) = [bmin, bmax];
      
      bdx = idx(i,1):idx(i,2);
      %plot(t(bdx),a(bdx),'r');
   end
end

%==========================================================================
% junk
%==========================================================================

function oo = Junk(o)                                                  
   t = o.data.t;
   
   if any(size(t)~=size(a))
      error('sizes of a and t do not match!');
   end

      % setup an order 1 filter
      
   T = (max(t) - min(t)) / 40;
   Fs = trf(1,[T 1]);
   f = rsp(Fs,abs(a),t);
   
   plot(t,f,'k');
   
   
   fm = max(f);
   fk = fm;
   
   level = 0.99:-0.01:0;
   for (k=1:length(level))
      fk = level(k) * fm;
      fdx = find(f>=fk);
      idx = [];
      while ~isempty(fdx)
         plot(fdx);
         jdx = fdx(:)' - (1:length(fdx));
         plot(jdx);
         jdx = find(jdx==jdx(1));
         idx(end+1,:) = fdx(1)+[0 length(jdx)-1];
         fdx(jdx) = [];
      end
      
      if (size(idx,1) >= 4)
         break;
      end
   end
   
   [m,n] = size(idx);
   cls(o);
   plot(t,a,'r');
   hold on;
   
   for (i=1:m)
      jdx = idx(i,1):idx(i,2);
      plot(t(jdx),a(jdx),'ko');
   end
end

%==========================================================================
% higher leel Crowd function
%==========================================================================

function [oo,cdx,t] = Crowd(o)                                         
%
% CROWD   Fetch current object from o and return crowd indices
%         Also prepare an epilog option
%
%            [oo,cdx] = Crowd(o)
%            epilog = opt(oo,'epilog')
%
   facette = opt(o,{'select.facette',0});
   %oo = current(o);
   oo = o;
   
   if (isa(facette,'double') && facette > 0)
      idx = crowd(oo);
      cdx = idx(facette,1):idx(facette,2);
      t = oo.data.t(cdx);
      oo = opt(oo,'epilog',sprintf('(Facette #%g)',facette));
   elseif (facette == 0)
      t = oo.data.t;
      cdx = 1:length(oo.data.t);
      oo = opt(oo,'epilog','(All)');
   elseif (facette == -1)
      idx = crowd(oo);
      cdx = [];
      t = [];  tend = 0;
      for (i=1:size(idx,1))
         jdx = idx(i,1):idx(i,2);
         cdx = [cdx,jdx];

         tjdx = o.data.t(jdx) - o.data.t(jdx(1));
         t = [t,tend+tjdx];
         tend = t(end) + 0.01;
      end
   end
end
