function lst = plist(obj)
% 
% PLIST    Retrieve parameter list of a DPROC object, which can be accessed by setp/getp methods
%      
%             obj = dproc(data)     % create DPROC object
%             lst = plist(obj);
%
%          See also   DISCO, DPROC

   common = {'name','text','type','kind','events','color','linetype','linewidth','start','stop'};
   
   switch kind(obj)
      case {'ramp','pulse'}
         lst = append(common,{'duration','level'});
      case {'sequence','chain'}
         lst = append(common,{'list'});
      case 'process'
         lst = append(common,{'list','period','baseline','baseskip','initial','lookup','threads','critical','fontsize'});
      otherwise
         lst = common;
   end
   return
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% auxillary functions
   
   function l = append(l1,l2)
      l = l1;
      n1 = length(l1);
      for (i=1:length(l2))
         l{n1+i} = l2{i};
      end
   return
   
% eof