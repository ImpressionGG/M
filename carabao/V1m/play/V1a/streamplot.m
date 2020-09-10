function streamplot(x,sym,col,par) % stream plot (v1a/streamplot.m)
%
% STREAMPLOT   Plot data stream: streamplot(x,'x','r',par)
%
   plot(x,col);                    % stream plot
   m = mean(x);                    % mean value
   s = std(x);                     % standard deviation (sigma)
    
   xlabel('data index');  
   ylabel([sym,' data']);
   format = '%s: %s-stream: mean %g, sigma %g';
   text = sprintf(format,par.title,sym,m,s);
   title(text);
end
