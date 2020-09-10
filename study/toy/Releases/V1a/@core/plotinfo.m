function plotinfo(obj,title,varargin)
%
% PLOTINFO   Setup or pop up plot information. 
%
%    The setup information is stored in the 'shell.plotinfo' settings
%
%       obj = core;                         % create SHELL object
%       plotinfo(obj,title,texts);          % setup plot info
%       plotinfo(obj,title,tx1,tx2,...);    % setup plot info
%       plotinfo(obj,[]);                   % reset plot info
%       plotinfo(obj);                      % pop up plot info
%
%    Example:
%
%       plotinfo(obj,'UC Footprint',{'green: pF1,pF2','blue: rU'});
%       plotinfo(obj,'UC Footprint','green: pF1,pF2','blue: rU');
%
%    See also: CHAMEO
%

   if (nargin == 1)
      info = setting('shell.plotinfo');
      if isempty(info)
         msgbox('No plot info available for current context!',...
                'Plot Info','help');
      else
         msgbox(info.text,info.title,'help','non-modal');
      end
   else
      info = [];
      if ~isempty(title)
         info.title = title;
         if isempty(varargin)
            info.text = '';
         elseif iscell(varargin{1})
            info.text = varargin{1};
         else
            info.text = varargin;
         end
      end
      setting('shell.plotinfo',info);   % reset plot info
   end
   return
end   
   