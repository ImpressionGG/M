function blk = bulk(obj)
%
% BULK   Get bulk data of a SHELL object
%
%           blk = bulk(obj)
%
%        See also: SHELL SMART
%
   dat = data(obj);   % access data
   blk = dat.bulk;
   return
   
%eof   