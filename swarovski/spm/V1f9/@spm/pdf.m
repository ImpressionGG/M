function oo = pdf(o,varargin)          % Save figure as pdf
%
% PDF  Save figure as PDF
%
%        pdf(o)                        % save current figure as PDF
%        pdf(o,tag)                    % save current figure as PDF
%
%    
%      See also: SPM, PLOT, ANALYSIS
%
   if (nargin == 0)
       oo = Pdf(o);
   elseif (nargin == 2)
       oo = Pdf(o,varargin{1});
   else
       error('1 or 2 input args expected');
   end
end

%==========================================================================
% Save Current Figure as PDF
%==========================================================================

function o = Pdf(o,args)               % Save Current Figure as PDF        

      % The first two lines measure the size of your figure (in inches). 
      % The next line configures the print paper size to fit figure size.
      % The last line uses the print command and exports a vector pdf 
      % document as the output.

   set(gcf,'Units','inches');    
   pos = get(gcf,'Position');
   set(gcf,...
    'PaperPosition',[0 0 pos(3:4)],...
    'PaperSize',[pos(3:4)]);

   path = Directory(o);
   if ~isempty(path)
       print('-dpdf','-painters','epsFig.pdf');
   end
end

%==========================================================================
% Get (create) PDF directory
%==========================================================================

function path = Directory(o)
    path = get(o,'dir');
    
    if isempty(path)
        path = pwd;
    end
    
    path = [path,'/','PDF'];
    
        % check existence of directory and create if not exist
        
    if ( exist(pwd) ~= 7 )
       [success,errmsg,errid] = mkdir(path);
       
       if (~success)
           message(o,'Error on creating directory',{path});
           path = '';
       end
    end
end