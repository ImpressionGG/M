function pts = points(obj,idx)
% 
% POINTS  Get points info of a TDMOBJ
%      
%             obj = tdmobj(data)    % create TDM object
%             pts = points(obj,i)   % points info
%             pts = points(obj)     % points info, i = 0
%
%          See also   DANA, TDMOBJ

   dat = data(obj);
   
   if ( nargin <= 1 ), idx = 1; end
   
% first dispatch property 'kind'
   
   switch property(obj,'kind')
   case 'CAP'
      total = length(obj.data.x{idx});
      n = floor(total / 8);
      if (8*n ~= total)
         error('Can only deal with multiples of 8 units');
      end
      pts = [n 8];
%pts = [8 n];
      return
   end
   
% next dispatch format   
   
   if format(obj,{'#TDM01','#TDM02','#BKB01','#BKB02','#TKP01','#TKP02','#BKB03'})
      sz = sizes(obj);     % pts = obj.data.points;             
      pts = sz([2 1]);
   elseif format(obj,{'#FPR01'})
      pts = obj.data.points - [length(dat.badx) length(dat.bady)];             
   elseif format(obj,{'#TDK01'})
      if ( idx==1 )
         pts = obj.data.calpoints;
      else
         pts = obj.data.points{idx-1};
      end
   elseif format(obj,'#TDK02')
      if ( nargin <= 1 ), idx = {1:length(count(obj))}; end
      list = iscell(idx);
      if (list), idx = idx{1}; end
      pts=cell(1,length(idx));
      for k=1:length(idx)
         pts{k} = dat.data{idx(k)}.points;
      end
      if (~list), pts = pts{1}; end
   else
      error(['bad format: ',dat.format]);
   end
   
% end
