function oo = plot(o,varargin)         % Cigarillo Plot Method
%
% PLOT   Cigarillo plot method
%
%           plot(o,'Plot1')            % user defined plot function #1
%           plot(o,'Plot2')            % user defined plot function #2
%           plot(o,'Plot3')            % user defined plot function #3
%           plot(o,'Show')             % show object
%           plot(o,'Animation')        % animation of object
%
   [gamma,oo] = manage(o,varargin,@Plot1,@Plot2,@Plot3,@Scatter);
   oo = gamma(oo);
end

%==========================================================================
% Local Plot Functions
%==========================================================================

function o = Plot1(o)                  % User Defined Plot Function #1 
   message(o,'Modify tpx.plot>Plot1 function!');
end
function o = Plot2(o)                  % User Defined Plot Function #2 
   message(o,'Modify tpx.plot>Plot2 function!');
end
function o = Plot3(o)                  % User Defined Plot Function #3 
   message(o,'Modify tpx.plot>Plot3 function!');
end
function o = Scatter(o)                % Scatter Plot                   
   cls(o);
   list = basket(o);                   % get basket list
   for (i=1:length(list))
      oo = list{i};
      x = cook(oo,'x','stream');
      y = cook(oo,'y','stream');
      scatter(x,y,'k');          % black scatter plot
      c = corrcoef(x,y);         % correlation coefficients
   
      xlabel('x data');  
      ylabel('y data');
      title(sprintf('%s: correlation coefficient %g',oo.par.title,c(1,2)));
   end
   if length(list) > 1
      title('Scatter Plot');
   end
end
