function list = symbol(o)
%
% SYMBOL   get symbol list of a CARMEL object. 
%
%             list = symbol(o)       % get list of data stream symbols
%          
%          The following formats are supported
%
%             vset:     vector set based trace object
%             stream:   stream based trace object
%             bulk:     bulk based data object
%             
%          See also: CARAMEL, CORE
%
   list = {};
   if ~container(o)
      list = fields(data(o));
   end
   return
   
%  try
%     list = {};
%     switch type(o)
%        case 'trace'
%           list = fields(data(o));
%           list = list(2:end);
% 
%        case {'vset','bulk'}
%           error('implementation restriction!');
%           list = data(o,'symbols');
%     end
%  catch
%     list = {};
%  end
end

   