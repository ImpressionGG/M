function hdl = splot(p,q,D,M,hdl)    % sloc plot
%
% SPLOT   Sloc 
%
%            splot(p,q,D)            % plot sloc positions & nominal distances
%            hdl = splot(p,q,D,hdl)  % plot sloc positions & nominal distances
%
   hdl = [];
   if (nargin < 5)
      hdl = [];
   end
   if (nargin < 4)
      M = ones(size(D));
   end
   if ( any(size(p)~=size(q)) )
      error('sizes of arg1 and arg2 do not match!');
   end

      % clear existing graphics
      
   if (isempty(hdl))
      clf
   else
      delete(hdl);
      hdl = [];
   end
      
   D = (D+D')/2;     % symmetrize!
   [m,n] = size(q);
   
   for (j=1:n)
      h1 = plot(p(1,j),p(2,j),'bo');
      hold on;
      h2 = plot(q(1,j),q(2,j),'ro');
      hdl = [hdl; h1(:); h2(:)];
   end
   
   for (i=1:n)
      for (j=1:i-1);
         if (1)
            q1 = q(:,i); q2 = q(:,j);
            line = [q1, q2];
            h = plot(line(1,:), line(2,:), 'b');
            hdl = [hdl; h(:)];

            v = q2 - q1;       % line vector
            m = (q1 + q2)/2;   % mid point vector
           
            if (norm(v)==0)
               e = 0*v;
            else
               e = v / norm(v);
            end
              
            d = D(i,j);                % asserted distance
            line = [m-d*e/2, m+d*e/2];
            h = plot(line(1,:), line(2,:), 'r');
            hdl = [hdl; h(:)];
            if (M(i,j))
               set(h,'linewidth',3);
            else
               set(h,'linewidth',1);
            end
         end
      end
   end

   set(gca,'xlim',[min(p(1,:))-4,max(p(1,:))+4]);
   set(gca,'ylim',[min(p(2,:))-4,max(p(2,:))+4]);  
   set(gca,'dataaspectratio',[1 1 1]);
   drawnow;
 end
 