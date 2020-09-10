function C = cindex(obj,Z,col)
%
% CINDEX    Calculate color index for given Z-array. Use object settings
%           to determine and respect proper color map.
%
%              C = cindex(obj,Z);
%
%           For color map 'pale' there is a special call:
%
%              C = cindex(obj,Z,col)
%              C = cindex(obj,Z,'r')    % selects only red spectrum
%
%           See also: QUANTANA, CMAP, SURF
%
   name = option(obj,'cmap.name');

   [mz,nz] = size(Z);
   Z = Z(:);
   
   if (isempty(name))
      name = 'any';
   end

   switch name
      case {'phase','alpha'}
         if (nargin >= 3)
            C = search(obj,Z,col);
         else
            C = zeros(size(Z));   % dimension setup
            C = round(angle(Z)/2/pi * 256);
            C = rem(C+256,256);
         end      
      case 'complex'
         if (nargin >= 3)
            C = search(obj,Z,col);
         else
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
         end
      case {'pale','jolly'}
         if (nargin >= 3)
            C = search(obj,Z,col);
         else
            error('missing color argument (arg3)');
         end
      otherwise
         if (nargin >= 3)
            Z = ones(size(Z));      % ???????????????? trial to fix it
            C = search(obj,Z,col);
         else         
            map = colormap;
            m = size(map,1);
            absZ = abs(Z);
            zmin = min(min(absZ));
            zmax = max(max(absZ));

            C = round((abs(Z)-zmin) / (zmax-zmin) * (m-1));
            M = m + ones(size(C));

            %C = min(C,M);
            C = rem(C+m,m);
         end
   end

      % map color index into caxis pseudo color index
               
   c = caxis;  m = size(colormap,1);
   C = c(1) + [c(2)-c(1)] * [C-1]/(m-1);
   C = reshape(C,mz,nz);
   return
   
   
%==========================================================================   
   
function C = search(obj,Z,col)
%
% SEARCH proper color index
%
   col = color(col);               % make sure that we work with RGB value!

   map = colormap;
   [m,n] = size(map);
   Col = ones(m,1)*col;            % convert row to a matrix
         
   norm2 = sum((map'-Col').^2);
   idx = find(norm2 == min(norm2));
   cidx0 = max(1,idx(1)-15);
      
   cidx = cidx0 + (0:15);
   cidx = cidx0 + 15*ones(1,16);
 
      % now apply
            
   map = map(cidx,:);
   m = size(map,1);
   
   absZ = abs(Z);
   zmin = min(min(absZ));
   zmax = max(max(absZ));
         
   if (zmax > zmin)
      C = round((abs(Z)-zmin) / (zmax-zmin) * (m-1));
   else
      C = 0*Z + 15;
   end
   
   if (any(C(:) > m | C(:) < 0))
      error('something strange!!!');
   end
   
   C = cidx0 + rem(C+m,m);
   return          
   