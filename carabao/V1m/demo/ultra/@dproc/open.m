function open(obj)
% 
% OPEN     Open a DPROC object
%      
%             obj = dproc(data)     % create DPROC object
%             open(obj);
%
%          See also   DISCO, DPROC

   dat = data(obj);
   mo = dat.moti;
   
   if strcmp(class(dat.moti),'moti')
      figure;
      plot(mo);
   end

% eof