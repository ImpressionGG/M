function [out1,out2] = kdata(obj,idx)
% 
% KDATA   Get calibration coordinates (K0) of a TDMOBJ
%      
%             obj = tdmobj(data)        % create TDM object
%             K = kdata(obj)            % list of 2D vector sets
%             K = kdata(obj,3)          % 2D vector set
%             [Kx,Ky] = kdata(obj)      % list of X- and Y-matrix array
%             [Kx,Ky] = adata(obj,3)    % X- and Y-matrix arrays
%
%          See also   DANA, TDMOBJ

%    data = obj.data;              % Rohdaten

   if ( nargin <= 1 ), idx = {1:count(obj)}; end
   list = iscell(idx);
   if (list), idx = idx{1}; end
%
% calculate kx, ky and k
%
   Kx=cell(1,length(idx)); Ky=cell(1,length(idx)); K=cell(1,length(idx));
   for i = 1:length(idx)
      pts = points(obj,idx(i));
      dst = distance(obj,idx(i));
   
      dx = dst(1);      % Abstand X
      dy = dst(2);      % Abstand y
   
      n = pts(1);       % Punkte X
      m = pts(2);       % Punkte Y
   
      kx = dx * (ones(m,1)*(1:n) - 1);
      ky = dy * ((1:m)'*ones(1,n) - 1);
      k = [kx(:) ky(:)]';

      Kx{i} = kx;  Ky{i} = ky;  K{i} = k;
   end

% leave list if scalar index is supported

   if ( ~list && length(idx) == 1 )
      K = K{1};  Kx = Kx{1};  Ky = Ky{1};  
   end 

% set output args

   if nargout <= 1
      out1 = K;
   else
      out1 = Kx;  out2 = Ky;
   end
   
% end
