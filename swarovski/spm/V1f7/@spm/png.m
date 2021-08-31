function oo = png(o,varargin)          % Save figure as png
%
% PNG  Save figure as PNG
%
%        png(o)                        % save current figure as PNG
%        png(o,tag)                    % save current figure as PNG
%
%      Options
%
%         folder             % provide folder name (default 'PNG')
%
%      See also: SPM, PLOT, ANALYSIS
%
   if (nargin == 0)
       oo = Png(o);
   elseif (nargin == 2)
       oo = Png(o,varargin{1});
   else
       error('1 or 2 input args expected');
   end
end

%==========================================================================
% Save Current Figure as PDF
%==========================================================================

function o = Png(o,args)               % Save Current Figure as PNG        
   path = Directory(o);
   path = [path,'/',args,'.png'];
   if ~isempty(path)
       saveas(gcf,path,'png');
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
    
    folder = opt(o,{'folder','PNG'});
    path = [path,'/',folder];
    
        % check existence of directory and create if not exist
        
    if ( exist(path) ~= 7 )
       [success,errmsg,errid] = mkdir(path);
       
       if (~success)
           message(o,'Error on creating directory',{path});
           path = '';
       end
    end
end