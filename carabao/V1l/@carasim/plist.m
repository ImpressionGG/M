function lst = plist(o)
% 
% PLIST   Retrieve parameter list of a CARASIM object, which can be 
%         accessed by setp/getp methods
%      
%            lst = plist(o);
%
%         See also: CARASIM

   common = {'name','text','type','kind','events','color','linetype',...
             'linewidth','start','stop'};
   
   switch kind(o)
      case {'step','pulse'}
         lst = [common,{'duration','level'}];
      case {'sequence','chain'}
         lst = [common,{'list'}];
      case 'process'
         lst = [common,{'list','period','baseline','baseskip',...
                'initial','lookup','threads','critical','fontsize'}];
      otherwise
         lst = common;
   end
end
