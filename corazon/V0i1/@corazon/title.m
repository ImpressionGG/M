function [txt,raw] = title(o)
%
% TITLE  Get object's title
%
%           title(o)                   % set title in figure window
%           [txt,raw] = title(o)       % get title text
%
%        Underscores are provided with escape characters ('\') for
%        output arg 'txt', while 'raw' is the output text in raw form.
%
%        See also: CUT, CUL
%
   if (nargout == 0)
      fig = o.either(figure(o),gcf);
      [~,raw] = title(o);
      set(fig,'name',raw);
      return
   end
   
   tit = get(o,{'title',[class(o),' object']});
   uscore=util(corazon,'uscore');      % short hand
   txt = tit;                          % by default
   
   pkg = get(o,'package');
   if ~isempty(pkg)
      txt = [tit,' (',pkg,')'];
   end
   
   nick = get(o,'nick');
   if ~isempty(nick) && ~isempty(pkg)
      txt = [nick,' (',pkg,' - ',tit,')'];
   elseif ~isempty(nick) && ~isempty(pkg)
      txt = [nick,' (',tit,')'];
   end
   
   raw = txt;
   txt = uscore(raw);
end