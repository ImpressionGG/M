function value = getp(obj,parameter)
% 
% GETP     Set a DPROC object parameter
%      
%             obj = dproc(data)                    % create DPROC object
%             value = getp(obj,parameter);         % get parameter
%
%          See also   DISCO, DPROC

   knd = kind(obj);
   dat = data(obj);
   
% if parameter spec. is missing then display list of settings
   
   if ( nargin <= 1)
      lst = plist(obj);
      for (i=1:length(lst))
         eval(['values.',lst{i},'=getp(obj,''',lst{i},''');']);
      end
      if (length(lst) > 0 )
         disp(values)
      end
      return
   end
   
% retrieve specified parameter   
   
   if ~isstr(parameter)
      error('arg2: parameter argument must be a string!');
   end
   
   parlist = plist(obj);
   switch parameter
      case parlist
         eval(['value=obj.data.',parameter,';']);
      otherwise
         error(['no support for parameter ''',parameter,'''!']);
   end
   
% eof