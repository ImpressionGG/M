function hdl = splot(p,col,clear)      % sloc plot
%
% SPLOT   Sloc 
%
%            splot(p)                  % plot sloc pos & nominal distances
%            hdl = splot(p)            % plot sloc pos & nominal distances
%
   if (nargin < 2)
      col = '';                        % no color provided 
   end
   if (nargin < 3)
      clear = 1;
   end
   
   hdl = [];
   [m,n] = size(p);
   
   if (clear)
      clf;
   end

   for (j=1:n)
      if (~isnan(p(1,j)) && ~isnan(p(2,j)))
         plot(p(1,j),p(2,j),'bo');
         hdl = text(p(1,j)+0.1,p(2,j)+0.1,sprintf('%g',j));
         set(hdl,'color','r');
         hold on;
      end
   end
   
   if (~isempty(col))
      center(p,col);                   % draw center
   end

   set(gca,'xlim',[min(p(1,:))-1,max(p(1,:))+1]);
   set(gca,'ylim',[min(p(2,:))-1,max(p(2,:))+1]);
   set(gca,'dataaspectratio',[1 1 1]);
   set(gca,'fontsize',20);
   drawnow;
 end
 