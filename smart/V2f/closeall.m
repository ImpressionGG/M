% CLOSEALL  Close all figures
%

% close all figures

   fig = gcf+1;
   while (fig ~= gcf)
      fig = gcf;
      close(gcf);
   end
   close(gcf);

% eof