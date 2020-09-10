function txt = info(obj)
% 
% INFO     Get info string of a DPROC object
%      
%             obj = dproc(data)     % create DPROC object
%             txt = info(obj);
%
%          See also   DISCO, DPROC

   knd = kind(obj);
   dat = data(obj);
   text = dat.text;
   
   if (~isempty(text)) text = [' - ',text]; end
      
% dispatch kind
      
   if strcmp(knd,'ramp') | strcmp(knd,'pulse');

      if length(dat.level) == 1
         txt = sprintf([name(obj),': ',type(obj),'(%g,[%g])',text],dat.duration,dat.level(1));
      else
         txt = sprintf([name(obj),': ',type(obj),'(%g,[%g,%g])',text],dat.duration,dat.level(1),dat.level(2));
      end

   elseif strcmp(knd,'wait');

      list = '';
      n = length(dat.events);
      for (i=1:n)
         if (i > 1) sep = ','; else sep = ''; end
         list = [list,sep,dat.events{i}];
      end
      if (length(list) > 50) list = [list(1:50),'...']; end
      txt = sprintf([name(obj),': ',type(obj),'(%g,{',list,'})',text],dat.duration(1));

   elseif strcmp(knd,'sequence');

      list = '';
      n = length(dat.list);
      for (i=1:n)
         if (i > 1) sep = ','; else sep = ''; end
         list = [list,sep,name(dat.list{i})];
      end
      if (length(list) > 50) list = [list(1:50),'...']; end
      txt = [name(obj),': ',type(obj),'(',list,')',text];

   elseif strcmp(knd,'chain');

      list = '';
      n = length(dat.list);
      for (i=1:n)
         if (i > 1) sep = ','; else sep = ''; end
         list = [list,sep,name(dat.list{i})];
      end
      if (length(list) > 50) list = [list(1:50),'...']; end
      txt = [name(obj),': ',type(obj),'(',list,')',text];

   else
      txt = [name(obj),': ',type(obj),text];
   end
   
% eof