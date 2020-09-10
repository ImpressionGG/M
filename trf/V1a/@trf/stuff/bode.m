function hdl = bode(obj,col)
%
% BODE     Draw Bode plot of transfer function
%
%             l = tff(1,[1 1]);      % create a transfer function
%             hdl = bode(L);         % draw bode plot
%             hdl = bode(L,'r');     % with red color
% 
%         See also: TFF, TRIM, DSP, NUM, DEN, BODE, STEP, BAXES, TAXES
%
   if (nargin < 2) col = 'r'; end

   L = data(obj);
   tffbode(L,col);
      
   tit = get(obj,'title');
   if (isempty(tit))
      title('Bode Plot');
   else
      title(['Bode Plot: ',tit]);
   end

   return
%   