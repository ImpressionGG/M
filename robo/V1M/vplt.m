function hdl = vplt(V,color)
%
% VPLT      Plot set of vectors. V must have 2 to 4 rows.
%           2 rows mean direct coordinate representation. 
%           3 and 4 rows mean homogeneous coordinate repre-
%           sentation. 
%
%           A 4-row matrix is transformed to direct coordinates
%           and then projected to x-y-plane.
%
%              vplt(v)
%              vplt([V1,NaN*v,V2,NaN*v,...,NaN*v,Vn])
%
%              hdl = vplt(v);   % return handle
%
%           See also: ROBO, VCAT, VTEXT, VRECT
%
   VV = [];
   idx=find(isnan(sum(V)));
   idx=[0,idx,size(V,2)+1];
   held = ishold;
   
   H = [];
   for(i=1:length(idx)-1)
      Vi = V(1:2,idx(i)+1:idx(i+1)-1);
      VV = [VV Vi];
      
      if (nargin >= 2)
         h = plot(Vi(1,:),Vi(2,:),color);
      else
         h = plot(Vi(1,:),Vi(2,:));
      end
      H = [H h];
      hold on
   end
   
   if nargout > 0
      hdl = H;
   else
      if (~held) hold off; end
   end
   
   figure(gcf);
   
% eof