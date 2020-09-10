function scatterplot(x,y,par) % black scatter plot (v1a/scatterplot.m)
%
% SCATTERPLOT   Draw a black scatter plot: scatterplot(x,y,par)
%
   scatter(x,y,'k');          % black scatter plot
   c = corrcoef(x,y);         % correlation coefficients
   
   xlabel('x data');  
   ylabel('y data');
   title(sprintf('%s: correlation coefficient %g',par.title,c(1,2)));
end
