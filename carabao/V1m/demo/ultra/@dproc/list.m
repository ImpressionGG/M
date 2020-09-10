function list(obj,mode,level)
% 
% LIST    List structore of a process
%      
%            list(obj,mode,level)
%            list(obj)         % mode = 0 (standard), level = 0 (indention level)
%
%         For easy listing object lists corresponding to a process:
%
%            list(prc,{dp1,dp2,...,dpn})
%            
%         See also   DISCO, DPROC

% check arguments

   if ( nargin < 2) mode = 0; end
   if ( nargin < 3) level = 0; end

   indent = setstr(' '+zeros(1,3*level));

   if iscell(mode)
      base = key(obj);
      for (i=1:length(mode))
         el = mode{i};
         if isempty(el)
            fprintf([indent,'[]\n']);
         elseif isa(el,'dproc')
            list(el,0,level+1);
         elseif isstr(el)
            fprintf([indent,el,'\n']);
         elseif iscell(el)
            fprintf('List %g\n',i);
            list(obj,el,level+1);
         elseif (el >= base)
            item = element(obj,el);
            list(item,0,level+1);
         end
      end
      return
   end

% go ahead

   knd = kind(obj);

   switch knd
      case {'ramp','delay','pulse','wait'}
         %fprintf(indent);
         %if (nargin >= 5) fprintf('(%g,%g): ',idxi,idxj); end
         fprintf([indent,info(obj),' (at %g)\n'],getp(obj,'start'));

      otherwise
         fprintf([indent,info(obj),'\n']);
         sz=sizes(obj);

         if strcmp(knd,'process')
            n = sz(1);
         else
            n = sz(2);
         end

         for (j=1:n)
            el = element(obj,j);
            list(el,mode,level+1);
         end
   end

% eof