function n = count(o,idx)
% 
% COUNT    Get number of measurements of a TDMOBJ
%      
%             o = danaobj(data)        % create DANA object
%             n = count(o)             % number vector of measurements
%             n = count(o,i)           % number of i-th series
%
%          See also   DANA, DANAOBJ

   dat = data(o);
   
% first check property count   

   prop = property(o,'count');
   
   switch prop
      case {'TKP_A','BKB_A'}
         [~,~,n] = sizes(o);
         %n = length(dat.ax);
      case 'CAP_A'
         n = length(o.data.x);
      case 'TDK_A'   % #TDK01
         n = length(dat.MessX);
      case 'TDK_B'   % #TDK02
         if ( nargin <= 1 ), idx = 1:length(dat.data); end
         n=NaN(1,length(idx));
         for i=1:length(idx)
            n(i) = length(dat.data{idx(i)}.Ax);
         end
      case 'RKK_A'
         n = length(o.data.x);
      case 'TDM_A'    % e.g. #TDM01, #TDM02
         n = length(dat.xy);     % number of measurements
      case 'FPR_A'    % e.g. #TDM01, #TDM02
         n = length(o.data.x);         % number of measurements
      otherwise   
         error(['bad format! ',format(o),' or count property ',prop]);
   end
end   

