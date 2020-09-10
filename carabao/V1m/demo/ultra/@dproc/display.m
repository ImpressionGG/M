function display(obj)
% 
% DISPLAY  Display a DPROC object
%      
%             obj = dproc(data)     % create DPROC object
%             display(obj);
%
%          See also   DISCO, DPROC

   knd = kind(obj);
   dat = data(obj);

   start = getp(obj,'start');
   stop = getp(obj,'stop');
   disp(['<',info(obj),sprintf(' @ %g->%g',start,stop),'>']);
end
