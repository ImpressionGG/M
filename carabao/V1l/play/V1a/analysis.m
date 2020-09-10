function analysis                % log data analysis (v1a/analysis.m)
   path = filedialog;            % open file dialog, select log file
   if ~isempty(path)             % if dialog not terminated with cancel
      [x,y,par] = read(path);    % read data (x,y) and parameters
      figure                     % open new figure
      scatterplot(x,y,par);      % draw black scatter plot
      figure                     % open new figure
      streamplot(x,'x','r',par); % plot x-stream in red color
      figure                     % open new figure
      streamplot(y,'y','b',par); % plot y-stream in blue color      
   end
end
