function oo = action(o,varargin)       % Perform a Trade Action        
%
% ACTION Perform trade actionT
%
%           oo = action(o,'Long1')    % Long1 action
%           oo = action(o,'Short1')   % Short1 action
%
%           oo = action(o,'Long2')    % Long2 action
%           oo = action(o,'Short2')   % Short2 action
%
%        Action types:
%
%           - Long1: run trade as long as low of a candle is less or equal
%                    bottom. Return object with type 'long1'
%
%        See also: TRADE, SHELL
%
   [gamma,oo] = manage(o,varargin,@Menu,@Callback,...
                       @Long1,@Short1, @Long2,@Short2);
   oo = gamma(oo);
end

%==========================================================================
% Action Menu
%==========================================================================

function o = Menu(o)
   oo = mseek(o,{'#','Select'});
   ooo = mitem(oo,'-');

      % add Select/Chart menu
   ooo = mitem(oo,'Action');
   oooo = mitem(ooo,'Long 1',{@Long1});
end

%==========================================================================
% Long1 and Short1 Trade
%==========================================================================

function o = Long1(o)                  % Perform a Long1 Trade         
   [t,bottom,open,low,close] = data(o,'t,bottom,open,low,close');
   
   buy = o.either(arg(o,1),1);         % buy index
   sell = length(t);                   % default sell index
   
   limit = bottom(buy);                % sell limit
   
   for (i=buy+1:length(t))             % at the end chart
      if (i == length(t))
         sell = i;
         limit = bottom(i);
         price = close(i);
         worst = low(i);
      elseif (low(i) <= bottom(i-1))
         sell = i;
         limit = bottom(i-1);          % adjust to last bottom
         price = limit;
         worst = low(i);
         break;
      end
   end
   
   o = type(o,'long1');
   o = var(o,'buy,sell,limit,price,worst',buy,sell,limit,price,worst);
end
function o = Short1(o)                 % Perform a Short1 Trade        
   [t,top,open,high,close] = data(o,'t,top,open,high,close');
   
   sell = o.either(arg(o,1),1);        % sell index
   buy = length(t);                    % default buy index
   limit = top(sell);                  % sell limit
   
   for (i=sell+1:length(t))
      if (i == length(t))              % at the end of chart
         buy = i;
         limit = top(i);
         price = open(i);
         worst = high(i);
      elseif (high(i) >= top(i-1))
         buy = i;
         limit = top(i-1);             % adjust to last top 
         price = limit;
         worst = high(i);
         break;
      end
   end
   
   o = type(o,'short1');
   o = var(o,'sell,buy,limit,price,worst',sell,buy,limit,price,worst);
end

%==========================================================================
% Long2 and Short2 Trade
%==========================================================================

function o = Long2(o)                  % Perform a Long2 Trade         
   [t,bottom,open,low,close] = data(o,'t,bottom,open,low,close');
   haikin = data(o,'haikin');
   
   buy = o.either(arg(o,1),1);         % buy index
   o = var(o,'buy,sell,limit,price,worst',[],[],[],[],[]);
   
   limit = bottom(buy);                % sell limit
   
   while (1)
      while (buy <= length(t))
         buy  = buy+1;
         if (haikin(buy-1) > 0)
            break;
         end
      end

      if (haikin(buy) <= 0)
         continue;                     % no more buy condition
      end
      
         % ok: at this index we buy! set sell same as buy
         
      sell = buy;
      
      while (sell+1 <= length(t) && haikin(sell) > 0)
         sell = sell+1;
      end
      
      break;
   end
   
   limit = open(sell);
   price = open(sell);
   worst = low(sell);
   
   o = type(o,'long2');
   o = var(o,'buy,sell,limit,price,worst',buy,sell,limit,price,worst);
end