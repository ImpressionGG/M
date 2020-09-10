function disp(obj)
%
% DISP   Display contents of a CORE object.
%
%    Syntax:
%       obj = core(parameter,data)
%       disp(obj)
%
%    See also: CORE INFO DISPLAY SET GET DATA TYPE
%

   fprintf([upper(class(obj)),': <',info(obj),'>\n']);
   fprintf(['  CLASS: ',class(obj),'\n']);
%  fprintf(['  CLASS: ',obj.class,'\n']);
%  fprintf(['  TAG: ',iif(isempty(obj.tag),'''''',obj.tag),'\n']);
   fprintf(['  TYPE: ',type(obj),'\n\n']);
   
   par = get(obj);
   if (isempty(par))
      fprintf(['  PARAMETER: []\n']);
   else
      fprintf(['  PARAMETER:\n']);
   disp(par);   
   end
   
   dat = data(obj);
   if (isempty(dat))
      fprintf(['  DATA: []\n']);
   else
      fprintf(['  DATA:\n']);
      disp(data(obj));   
   end
   
end  