function [d,df,sym] = cook(o,sym,mode)
%
% COOK  Cook up data
%
%          [d,df] = cook(o,sym,mode)
%          [d,df] = cook(o,sym)           % mode = 'stream'
%
%          t = cook(o,':')                % get time vector 
%          x = cook(o,'x')                % get x data 
%          y = cook(o,'y')                % get y data 
%
%          [x,xf] = cook(o,'x')           % get x and filtered x data 
%          [y,yf] = cook(o,'y')           % get y and filtered y data
%
%          [d,df,sym] = cook(o,'t',mode)  % return ':' as sym
%
%     Copyright(c): Bluenetics 2020 
%
%        See also: CORAZON, FILTER, PLOT
%
   if container(o)
      d = [];  df = [];
      return
   end
   
   if isequal(sym,'t') || isequal(sym,':')
      d = data(o,'t');
      if (nargout > 1)
         df = d;
      end
      sym = ':';
      return
   end
   
   d = data(o,sym);
   if (nargout > 1)
      t = data(o,'t');
      oo = with(o,'filter');              % unpack filter options
      df = filter(oo,d,t);
   end
end

