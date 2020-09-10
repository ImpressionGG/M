function obj = setp(obj,varargin)
% 
% SETP     Set a DPROC object parameter
%      
%             obj = dproc(data)                    % create DPROC object
%             obj = setp(obj,parameter,value);     % see handle graphics set/get features
%
%          See also   DISCO, DPROC

   knd = kind(obj);
   dat = data(obj);
   
   if ( rem(length(varargin),2) > 0) 
      error('arguments must be provied as couples of parameter-value pairs!'); 
   end
   
   parlist = plist(obj);
   for (i=1:2:length(varargin))
      parameter = varargin{i};  value = varargin{i+1};
      
      if ~isstr(parameter)
         error('parameter argument must be a string!');
      end
      
      switch parameter
         case parlist
            eval(['obj.data.',parameter,'=value;']);
         otherwise
            error(['no support for parameter ',parameter,'!']);
      end
   end
   
% eof