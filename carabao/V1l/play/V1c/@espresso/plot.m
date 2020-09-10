function oo = plot(o,varargin)         % Espresso Plot Method          
%
% PLOT   Espresso plot method
%
%           plot(o,'Scatter')          % user defined plot function #1
%           plot(o,'Xstream')          % user defined plot function #2
%           plot(o,'Ystream')          % user defined plot function #3
%           plot(o,'Ensemble')         % ensemble analysis
%
   [gamma,oo] = manage(o,varargin,@Scatter,@Xstream,@Ystream,@Ensemble);
   oo = gamma(oo);
end

%==========================================================================
% Local Plot Functions
%==========================================================================

function o = Scatter(o)                % Scatter Plot                  
   cls(o);                             % clear screen
   list = basket(o);                   % get list of objects in basket
   for (i=1:length(list))
      oo = list{i};
      scatterplot(oo.data.x,oo.data.y,oo.par); 
      hold on; 
   end
   if length(list) > 1
      title(get(o,{'title','Espresso Shell'}));
   end
   what(o,'Scatter Plot','scatter plot y(x) of log data');
end

function o = Xstream(o)                % Stream Plot For X-Data        
   cls(o);                             % clear screen
   list = basket(o);                   % get list of objects in basket
   for (i=1:length(list))
      oo = list{i};
      streamplot(oo.data.x,'x','r',oo.par);  
      hold on
   end
   if length(list) > 1
      title(get(o,{'title','Espresso Shell'}));
   end
   what(o,'X-Stream Plot','x-stream of log data over index');
end

function o = Ystream(o)                % Stream Plot For Y-Data        
   cls(o);                             % clear screen
   list = basket(o);                   % get list of objects in basket
   for (i=1:length(list))
      oo = list{i};
      streamplot(oo.data.y,'y','b',oo.par);  
      hold on
   end
   if container(current(o))
      title(get(o,{'title','Espresso Shell'}));
   end
   what(o,'Y-Stream Plot','x-stream of log data over index');
end

function o = Ensemble(o)               % Ensemble Analysis             
   refresh(o,{'plot','Ensemble'});     % update refresh callback
   o = opt(o,'basket.collect','*');    % all objects of the container
   o = opt(o,'basket.type','shell');   % only 'shell' typed objects
   
   list = basket(o);  
   n = length(list);
   
   if (isempty(list))
      message(o,'No objects in basket!');
      return
   end
   
   hax = cls(o);
   for (i=1:n)
      oo = list{i};
      sx(i) = std(oo.data.x);
      sy(i) = std(oo.data.y);
      c = corrcoef(oo.data.x,oo.data.y);  cc(i) = c(1,2);
   end
   
   hax = subplot(211);
   plot(hax,1:n,sx,'r', 1:n,sy,'b', 1:n,sx,'r.', 1:n,sy,'b.');
   set(hax,'xtick',1:n);
   title('Standard Deviation x(red), y(blue)');

   hax = subplot(212);
   plot(hax,1:n,cc,'k',1:n,cc,'k.');
   set(hax,'xtick',1:n);
   title('Correlation Coefficient');

   what(o,'Analysis of Ensemble',...
          'standard deviations x/y','correlation coefficient');
end
