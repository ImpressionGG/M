function [out1,out2] = adata(obj,idx)
% 
% ADATA   Get actor coordinate matrix of a TDMOBJ
%      
%             obj = tdmobj(data)        % create TDM object
%             A = adata(obj)            % list of 2D vector sets A
%             A = adata(obj,3)          % 2D vector set A
%             [Ax,Ay] = adata(obj)      % list of X- and Y-matrix array
%             [Ax,Ay] = adata(obj,3)    % X- and Y-matrix arrays
%
%          Note: With given Q-coordinates one comes to A-coordinates by
%                adding correction matrix:
%
%                   A = Q0 + C0;   
%                   A = Q1 + C1;   
%
%                A: actor coordinates
%                Q0/Q1: level 0/1 isometric pickup coordinates
%                C0/C1: level 0/1 actor coordinate correction
%
%          See also   DANA, TDMOBJ
%
   is = @bazaar.is;                    % need some utility
   fmt = format(obj);
   dat = data(obj);                    % raw data
   
   if ( nargin <= 1 )
      idx = {1:count(obj)};
   end
   list = iscell(idx);
   if (list)
      idx = idx{1};
   end
   
% calculate Ax, Ay and A

   if is(fmt,{'#TDM01','#FPR01'})
      [Kx,Ky] = kdata(obj,{idx});      % calibration coordinates
      [Cx,Cy] = cdata(obj,{idx});     % correction values
      Ax=cell(1,length(idx)); Ay=cell(1,length(idx)); A=cell(1,length(idx));
      for i=1:length(idx)              % with format #TDM01 we do not
         Ax{i} = Kx{i} + Cx{i};        % realy know the actor coordinates,
         Ay{i} = Ky{i} + Cy{i};        % so we assume A = K + C
         A{i} = vset(Ax{i},Ay{i});
      end
   elseif is(fmt,{'#TDM02'})
      pts = dat.points;
      matrix(pts([2 1]));
      Ax=cell(1,length(idx)); Ay=cell(1,length(idx)); A=cell(1,length(idx));
      for i=1:length(idx)
         NI = dat.iterations(i);  % number of iterations
         xy = dat.xy{idx(i)};     % raw data 
         n = 2*(1+NI);
         m = length(xy(:))/n;
         xy = reshape(xy,n,m)';
         a = xy(:,1:2)';
         for j=1:abs(NI),
            a = a + sign(NI)*xy(:,(2*j+1):(2*j+2))';
         end
         a = reorder(a);
         if any(any(dat.stretch ~= eye(2)))
            k = kdata(obj,idx(i));
            c = resi(k,a);
            q = a-c;
            M = dat.stretch;  phi = M(2,1);  M(2,1) = 0;  K = diag(diag(M));  S = K\M;
            a = rot(phi)*S*q + K*c;
         end
         [ax,ay] = matrix(a);
         A{i} = a;  Ax{i} = ax;  Ay{i} = ay;
      end
   elseif is(fmt,{'#TDK01'})
      [Kx,Ky] = kdata(obj,{idx});
      Ax=cell(1,length(idx)); Ay=cell(1,length(idx)); A=cell(1,length(idx));
      for i=1:length(idx)              % with format #TDM01 we do not
         if ( idx(i) == 1 )
            Ax{i} = dat.calAchsKoordX;
            Ay{i} = dat.calAchsKoordY;
         else
            Ax{i} = Kx{i} + dat.MessX{idx(i)};
            Ay{i} = Ky{i} + dat.MessY{idx(i)};
         end
         A{i} = vset(Ax{i},Ay{i});
      end
   elseif is(fmt,{'#BKB01','#TKP01','#TKP02'})
      obj = opt(obj,'scope',idx);
      Ax = cook(obj,'ax','matrix');
      Ay = cook(obj,'ay','matrix');
      for i=1:length(idx)              % with format #TDM01 we do not
         A{i}  = vset(Ax{i},Ay{i});
      end
   elseif is(fmt,{'#BKB02','#BKB03'})
%       Ax=cell(1,length(idx)); Ay=cell(1,length(idx)); A=cell(1,length(idx));
%       for i=1:length(idx)              % with format #TDM01 we do not
%          k = idx(i);
%          ax = obj.data.Ax{k};
%          ay = obj.data.Ay{k};
% 
%          Ax{i} = ax;
%          Ay{i} = ay;
%          A{i}  = vset(Ax{i},Ay{i});
%       end
      obj = opt(obj,'scope',idx);
      Ax = cook(obj,'ax','matrix');
      Ay = cook(obj,'ay','matrix');
      for i=1:length(idx)              % with format #TDM01 we do not
         A{i}  = vset(Ax{i},Ay{i});
      end
   else
      error('format not supported!');
   end

% leave list if scalar index is supported

   if ( ~list && length(idx) == 1 )
      A = A{1};  Ax = Ax{1};  Ay = Ay{1};  
   end 

% set output arguments
   
   if nargout <= 1
      out1 = A;
   else
      out1 = Ax;  out2 = Ay;
   end
end

