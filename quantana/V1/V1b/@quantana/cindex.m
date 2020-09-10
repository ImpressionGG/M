function C = cindex(obj,Z)
%
% CINDEX    Calculate color index for given Z-array. Use object settings
%           to determine and respect proper color map.
%
%           See also: QUANTANA, CMAP, SURF
%
   name = option(obj,'cmap.name');

   switch name
      case 'phase'
         C = zeros(size(Z));   % dimension setup
         C = round(angle(Z)/2/pi * 256);
         C = rem(C+256,256);
         return;
      
      case 'complex'
         map = colormap;
         NN = size(map,1);
         N = sqrt(NN);
         M = N/4;  N = N*4;
         M = floor(M);  N = floor(N);
         
         if (M*N ~= NN)
            error('cannot handle colormap!');
         end
         
         C = round(angle(Z)/2/pi * N);
         C = rem(C+N,N);
   
         Z = abs(Z);

         B = N * round((M-1)*Z/max(Z(:)));   % brightness index 
         C = B+C;

         if (any(any(C>=M*N)) || any(any(C<0))) 
            error('bad color index');
         end
         return
         
      otherwise
         map = colormap;
         m = size(map,1);
         absZ = abs(Z);
         zmin = min(min(absZ));
         zmax = max(max(absZ));
         
         C = (abs(Z)-zmin) / (zmax-zmin) * (m-1);
         M = m + ones(size(C));
         
         %C = min(C,M);
         C = rem(C+m,m);
   end
   return
   
   
   
