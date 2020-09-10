function symlist = symbol(obj)
%
% SYMBOL   get symbol list of a SMART object. SMART Object is expected to
%          be of #BULK format
%
%             symlist = symbol(obj)
%          
%          See also: SMART BULK
%
   fmt = format(obj);
   
   if ~strcmp(fmt,'#BULK')
      error('#BULK format expected for object!');
   end
   
   dat = data(obj);
   symlist = dat.symbols;
   return
   
%eof   