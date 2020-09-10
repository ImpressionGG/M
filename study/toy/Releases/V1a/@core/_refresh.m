function [out1,out2] = refresh(obj,callback,callargs)
%
% REFRESH    Refresh figure; invoke refreshment callback which has been
%            prepared for figure refreshment. This function can also be
%            used for handling key-press events.
%
%            Refresh can be called with 1 or 3 args
%
%               refresh(obj)                   % invoke refreshing callback
%               [callback,callargs] = refresh(obj) % return settings (no invoke)
%
%               refresh(obj,callback,callargs) % setup refreshing callback
%               obj = refresh(obj,cback,cargs) % set options
%
%            Setup current function as refresh function
%
%               refresh(obj,inf);    % setup current function for refresh
%               refresh(obj,[]);     % disable refresh callback
%
%            Note: priviously there was also a compatibility call syntax
%                  with two input arguments. Except to the two calls above
%                  this is now obsolete and will end up in an error
%
%               refresh(obj,cbo)    % generates an error
%
%            Examples for callback setup:
%
%               refresh(gfo,'datainfo(obj)',[]);
%               refresh(gfo,'compinfo(obj)',[]);
%               refresh(gfo,'analyse(obj,''CbExecute'');','CbOverview');
%               refresh(gfo,'analyse(obj)',{'CbExcecute','CbOverview'});
%
%            See also: SHELL MENU CBSETUP CBRESET

     % if the calling syntax has two output args we just retrieve the
     % shell settings
     
   if (nargout == 2)
      out1 = setting('shell.callback');
      out2 = setting('shell.callargs');
      return
   end
   
     % previously we got cmd and callarg from the settings. This does not 
     % work if we launch an object from M-file. Thus we changed the code
     % to get this information from the options

   if (nargin == 1)
      callback = option(obj,'shell.callback');
      callargs = option(obj,'shell.callargs');

      obj = arg(obj,callargs);
      if isstr(callback)
         if option(obj,'shell.debug')
            eval(callback);
         else
            try
               eval(callback);
            catch
               fprintf(['*** Could not execute callback: ',callback,'\n']);
               callargs
            end
         end
      end
      return
   end
   
% Handle the obsolete case with 2 callargs

   if (nargin == 2)
      arg2 = callback;
      if isempty(arg2)              % deactivate refresh callback
         cbsetup(obj,'','');
      elseif isinf(arg2)            % set current callback for refresh
         cbsetup(obj,inf);
      else
         error('A call to REFRESH with two args is obsolete! Call with 1 arg instead!');
         callargs = args(obj);   % prepared
      end
   end

% A call with 3 args will setup the refresh callback and args

   if (nargin == 3)
      if (nargout == 0)
         cbsetup(obj,callback,callargs);
      else
         out1 = cbsetup(obj,callback,callargs);
      end
      return
   end
   
   return