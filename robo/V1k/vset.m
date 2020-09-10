function V = vset(arg1,arg2,arg3,arg4)
%
% VSET      Create a 2D or 3D vector set
%
%              V = vset(Vx,Vy)
%              V = vset(Vx,Vy,Vz)
%
%           As an option matrix order can be specified:
%
%              V = vset('BLR',Vx,Vy)   % bottom-left/right
%              V = vset('BLU',Vx,Vy)   % bottom-left/up
%              V = vset('TLR',Vx,Vy)   % top-left/right
%              V = vset('TLD',Vx,Vy)   % top-left/down
%
%           Note:
%
%              vset(Vx,Vy,Vz) = vset(Vx(:),Vy(:),Vz(:))
%
%           See also: ROBO, VPLT
%

% Change history
%    2009-12-05 introduce order specs (BLR,BLU,TLR,TLD) (Robo/V1k)

   if (isstr(arg1))
       if (nargin == 3)
          order = arg1;  Vx = arg2;  Vy = arg3;  dim = 2;
       elseif (nargin == 4)
          order = arg1;  Vx = arg2;  Vy = arg3;  Vz = arg4;  dim = 3;
       else
          error('3 or 4 args expected!');
       end
   else
       order = 'BLU';
       if (nargin == 2)
          Vx = arg1;  Vy = arg2;  dim = 2;
       elseif (nargin == 3)
          Vx = arg1;  Vy = arg2;  Vz = arg3;  dim = 3;
       else
          error('2 or 3 args expected!');
       end
   end
       
      % start to work 
       
   [m,n] = size(Vx);
   
   switch order
   case 'BLU'
       % done
   case 'BLR'
       Vx = Vx';  Vy = Vy';
       if (dim >= 3) Vz = Vz'; end 
   case 'TLD'
       Vx = Vx(m:-1:1,:);  Vy = Vy(m:-1:1,:);
       if (dim >= 3) Vz = Vz(m:-1:1,:); end 
   case 'TLR'
       Vx = Vx(m:-1:1,:)';  Vy = Vy(m:-1:1,:)';
       if (dim >= 3) Vz = Vz(m:-1:1,:)'; end 
   otherwise
      error(['bad arg1 (order): ',order]);        
   end
   
   if (dim == 2)
      V = [Vx(:),Vy(:)]';
   elseif (dim == 3)
      V = [Vx(:),Vy(:),Vz(:)]';
   end

% eof